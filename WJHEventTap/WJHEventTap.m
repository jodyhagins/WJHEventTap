//
//  WJHEventTap.m
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHEventTap.h"
#import "NSValue+WJHEventTap.h"
#import "NSDictionary+WJHEventTap.h"

static ProcessSerialNumber currentPSN();
static CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userData);


#pragma mark - WJHEventTap Private API
@interface WJHEventTap()
/**
 When an event is created in the system, it is usually automatically enabled.  However, we want to start with it disabled.  Between the time we create the tap and when it is disabled, it is possible for it to have received events.  At minimum, it will have received the user-disabled event.  These events are eventually delivered (because the tap was enabled) to the callback handler.  We use this flag to indicate whether or not we are in the initial event-swallowing mode.
 */
@property (nonatomic, assign) BOOL swallowEvents;
@end


#pragma mark - WJHEventTap Class

@implementation WJHEventTap {
    CFMachPortRef _tap;
    CFRunLoopSourceRef _runLoopSource;
}

#pragma mark Obtain System Tap Info

+ (uint32_t)systemTapCount {
    uint32_t tapCount;
    CGGetEventTapList(0, NULL, &tapCount);
    return tapCount;
}

static inline void myfree(void *ptr) {
    free(*(void**)ptr);
}

+ (NSArray *)systemTapsWithTransform:(id(^)(CGEventTapInformation const *tapInfo))block {
    uint32_t count = [self systemTapCount];
    if (count == 0) return [NSArray array];

    if (block == nil) {
        block = ^id(CGEventTapInformation const *tapInfo) {
            return [NSValue wjh_valueWithCGEventTapInformation:*tapInfo];
        };
    }

    // Want bytes to be zero, so padding bytes are in a known state.
    __attribute__ ((cleanup(myfree))) CGEventTapInformation *tapInfo = calloc(count, sizeof(*tapInfo));

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    if (CGGetEventTapList(count, tapInfo, &count) == kCGErrorSuccess) {
        for (uint32_t i = 0; i < count; ++i) {
            id object = block(tapInfo + i);
            if (object) {
                [result addObject:object];
            }
        }
    }

    return [result copy];
}

+ (NSArray*)systemTaps {
    return [self systemTapsWithTransform:nil];
}


# pragma Init/Fini

- (void)setupLocation:(id)location {
    NSAssert(_tap == nil, @"Tap should not be created");
    if ([location isKindOfClass:[NSNumber class]]) {
        _location = (CGEventTapLocation)[location unsignedIntegerValue];
        if (_location == kWJHProcessEventTap) {
            _processSerialNumber = currentPSN();
        } else {
            memset(&_processSerialNumber, 0, sizeof(_processSerialNumber));
        }
    } else {
        _location = kWJHProcessEventTap;
        _processSerialNumber = *(ProcessSerialNumber*)[location pointerValue];
    }
}

- (void)setupTap {
    CGEventTapPlacement placement = self.beforeOthers ? kCGHeadInsertEventTap : kCGTailAppendEventTap;
    CGEventTapOptions options = self.passive ? kCGEventTapOptionListenOnly : kCGEventTapOptionDefault;
    if (_location == kWJHProcessEventTap) {
        _tap = CGEventTapCreateForPSN(&_processSerialNumber, placement, options, self.requestedEventMask, eventTapCallback, (__bridge void*)self);
    } else {
        _tap = CGEventTapCreate(self.location, placement, options, self.requestedEventMask, eventTapCallback, (__bridge void*)self);
    }
}

- (instancetype)initWithGenericLocation:(id)location eventMask:(CGEventMask)eventMask beforeOthers:(BOOL)beforeOthers passive:(BOOL)passive runLoop:(NSRunLoop *)runLoop delegate:(id<WJHEventTapDelegate>)delegate {
    if (self = [super init]) {
        _requestedEventMask = eventMask;
        _runLoop = runLoop ?: [NSRunLoop currentRunLoop];
        _beforeOthers = beforeOthers;
        _passive = passive;
        _delegate = delegate;
        _swallowEvents = YES;
        [self setupLocation:location];

        // I can't find an API to get my own tap's unique eventTapID, so we will need to grab the list of taps both before and after installing our own, and hope that there is only one new tap in the list.  Since we can't guarantee that another tap was inserted at the same time, we need to loop until we see only our tap as the new tap.
        for (;;) {
            NSSet *before = [NSSet setWithArray:[self.class systemTaps]];
            [self setupTap];
            if (_tap == nil) {
                return self = nil;
            }

            if (CGEventTapIsEnabled(_tap)) {
                CGEventTapEnable(_tap, false);
            } else {
                self.swallowEvents = NO;
            }

            NSMutableSet *after = [NSMutableSet setWithArray:[self.class systemTaps]];
            [after minusSet:before];
            if (after.count == 1) {
                CGEventTapInformation info = [[after anyObject] wjh_CGEventTapInformationValue];
                _eventTapID = info.eventTapID;
                _eventMask = info.eventsOfInterest;
                break;
            } else {
                // Could not find our tap... try again.
                CFMachPortInvalidate(_tap);
                CFRelease(_tap);
                _tap = nil;
            }
        }

        NSAssert(_tap != nil, @"BUG: Should have already bailed");
        _runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _tap, 0);
        CFRunLoopAddSource([_runLoop getCFRunLoop], _runLoopSource, kCFRunLoopCommonModes);
    }
    return self;
}

- (instancetype)initWithLocation:(CGEventTapLocation)location eventMask:(CGEventMask)eventMask beforeOthers:(BOOL)beforeOthers passive:(BOOL)passive runLoop:(NSRunLoop *)runLoop delegate:(id<WJHEventTapDelegate>)delegate {
    NSNumber *locNum = [NSNumber numberWithUnsignedInteger:(NSUInteger)location];
    return [self initWithGenericLocation:locNum eventMask:eventMask beforeOthers:beforeOthers passive:passive runLoop:runLoop delegate:delegate];
}

- (instancetype)initWithProcess:(ProcessSerialNumber *)process eventMask:(CGEventMask)eventMask beforeOthers:(BOOL)beforeOthers passive:(BOOL)passive runLoop:(NSRunLoop *)runLoop delegate:(id<WJHEventTapDelegate>)delegate {
    ProcessSerialNumber psn;
    if (process) {
        psn = *process;
    } else {
        psn = currentPSN();
    }
    return [self initWithGenericLocation:[NSValue valueWithPointer:&psn] eventMask:eventMask beforeOthers:beforeOthers passive:passive runLoop:runLoop delegate:delegate];
}

- (void)dealloc {
    _delegate = nil;
    if (_runLoopSource) {
        CFRunLoopSourceInvalidate(_runLoopSource);
        CFRelease(_runLoopSource);
        _runLoopSource = NULL;
    }
    if (_tap) {
        CFMachPortInvalidate(_tap);
        CFRelease(_tap);
        _tap = NULL;
    }
}

#pragma mark Is Enabled

- (BOOL)isEnabled {
    return _tap ? CGEventTapIsEnabled(_tap) : NO;
}

- (void)setEnabled:(BOOL)enabled {
    NSAssert(_tap != nil, @"Tap has disappeared");
    enabled = !!enabled;
    BOOL current = !!self.isEnabled;
    if (current != enabled) {
        CGEventTapEnable(_tap, enabled);
    }
}

@end




#pragma mark - Implementation Details

static ProcessSerialNumber currentPSN() {
    // Argh.  GetCurrentProcess() is deprecated in favor of [NSRunningApplication currentApplication].  However, it provides no API to get the ProcessSerialNumber, which is required to create an application tap.  Hopefully, this gets fixed in a future release, where we either gain access to ProcessSerialNumber, or we get another API to install process taps.
    ProcessSerialNumber psn;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GetCurrentProcess(&psn);
#pragma clang diagnostic pop
    return psn;
}

static CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userData) {
    WJHEventTap *tap = (__bridge WJHEventTap *)(userData);
    id<WJHEventTapDelegate> delegate = tap.delegate;

    if (tap.swallowEvents) {
        if (type == kCGEventTapDisabledByUserInput) {
            // This should be our manual disable when we created the tap
            tap.swallowEvents = NO;
        }
        return event;
    }

    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        if (tap.isEnabled) {
            // The "Disable" event was enqueued, but the tap has since been re-enabled, so ignore the event.
            return event;
        }
        tap.enabled = NO;
    }

    if ([delegate respondsToSelector:@selector(eventTap:receivedEvent:type:proxy:)]) {
        CGEventRef tmpEvent = event;
        if ([delegate eventTap:tap receivedEvent:&tmpEvent type:type proxy:proxy]) {
            return tmpEvent;
        }
    }

#define invokeDelegate(_name_) \
if ([delegate respondsToSelector:@selector(eventTap:_name_:proxy:)]) { \
return [delegate eventTap:tap _name_:event proxy:proxy]; \
} break

    switch (type) {
        case kCGEventNull:
            invokeDelegate(nullEvent);
        case kCGEventLeftMouseDown:
            invokeDelegate(leftMouseDownEvent);
        case kCGEventLeftMouseDragged:
            invokeDelegate(leftMouseDraggedEvent);
        case kCGEventLeftMouseUp:
            invokeDelegate(leftMouseUpEvent);
        case kCGEventRightMouseDown:
            invokeDelegate(rightMouseDownEvent);
        case kCGEventRightMouseDragged:
            invokeDelegate(rightMouseDraggedEvent);
        case kCGEventRightMouseUp:
            invokeDelegate(rightMouseUpEvent);
        case kCGEventOtherMouseDown:
            invokeDelegate(otherMouseDownEvent);
        case kCGEventOtherMouseDragged:
            invokeDelegate(otherMouseDraggedEvent);
        case kCGEventOtherMouseUp:
            invokeDelegate(otherMouseUpEvent);
        case kCGEventMouseMoved:
            invokeDelegate(mouseMovedEvent);
        case kCGEventKeyDown:
            invokeDelegate(keyDownEvent);
        case kCGEventKeyUp:
            invokeDelegate(keyUpEvent);
        case kCGEventFlagsChanged:
            invokeDelegate(modifierFlagsChangedEvent);
        case kCGEventScrollWheel:
            invokeDelegate(scrollWheelEvent);
        case kCGEventTabletPointer:
            invokeDelegate(tabletPointerEvent);
        case kCGEventTabletProximity:
            invokeDelegate(tabletProximityEvent);
        case kCGEventTapDisabledByTimeout:
            invokeDelegate(eventTapDisabledByTimeoutEvent);
        case kCGEventTapDisabledByUserInput:
            invokeDelegate(eventTapDisabledByUserInputEvent);
        default:
            if ([delegate respondsToSelector:@selector(eventTap:unknownEvent:type:proxy:)]) {
                return [delegate eventTap:tap unknownEvent:event type:type proxy:proxy];
            }
            break;
    }
    
    return event;
}
