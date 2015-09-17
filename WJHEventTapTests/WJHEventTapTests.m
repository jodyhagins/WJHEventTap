//
//  WJHEventTapTests.m
//  WJHEventTapTests
//
//  Created by Jody Hagins on 9/17/15.
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
@import WJHEventTap;

@interface WJHEventTapTests : XCTestCase
@end

typedef CGEventRef (^EventBlock)(WJHEventTap *eventTap, CGEventRef event, CGEventTapProxy proxy);
@implementation WJHEventTapTests {
    WJHEventTapDelegate *delegate;
}

- (XCTestExpectation *)wjh_intervalExpectation:(NSTimeInterval)interval predicate:(BOOL(^)(void))predicate {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);

    XCTestExpectation *result = [self expectationWithDescription:[NSString stringWithFormat:@"timedExpectation:%.04f", interval]];
    __weak XCTestExpectation *weakExpectation = result;
    dispatch_source_set_event_handler(timer, ^{
        XCTestExpectation *expectation = weakExpectation;
        if (expectation) {
            if (predicate()) {
                dispatch_source_cancel(timer);
                [expectation fulfill];
            }
        } else {
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
    return result;
}

- (void)setUp {
    [super setUp];
    delegate = [WJHEventTapDelegate new];
}


#pragma mark - Tests

- (void)testSystemTapCount {
    uint32_t count;
    CGGetEventTapList(0, NULL, &count);
    XCTAssertEqual(count, [WJHEventTap systemTapCount]);
}

static inline void myfree(void *ptr) {
    free(*(void**)ptr);
}

- (void)testSystemTaps {
    // Most sytems have at least one tap installed, but we should make sure we have at least one.
    NS_VALID_UNTIL_END_OF_SCOPE WJHEventTap *tap = [self makePassiveTap];

    // Get available taps with the C API
    uint32_t count;
    __attribute__ ((cleanup(myfree))) CGEventTapInformation *tapInfo = NULL;

    XCTAssertTrue(getSystemTapsWithCAPI(&tapInfo, &count));

    // Get the taps using our class method
    NSArray *taps = [WJHEventTap systemTapsWithTransform:nil];

    // They should be identical
    XCTAssertEqual(count, taps.count);
    for (NSUInteger i = 0; i < taps.count; ++i) {
        CGEventTapInformation ti = [taps[i] wjh_CGEventTapInformationValue];
        XCTAssertEqual(0, memcmp(tapInfo+i, &ti, sizeof(ti)));
    }
}

- (void)testEventTapID {
    NSMutableSet *beforeTapIDs = [NSMutableSet set];
    for (NSValue *v in [WJHEventTap systemTaps]) {
        CGEventTapInformation tapInfo = v.wjh_CGEventTapInformationValue;
        [beforeTapIDs addObject:@(tapInfo.eventTapID)];
    }

    WJHEventTap *tap = [self makePassiveTap];

    NSMutableSet *afterTapIDs = [NSMutableSet set];
    for (NSValue *v in [WJHEventTap systemTaps]) {
        CGEventTapInformation tapInfo = v.wjh_CGEventTapInformationValue;
        NSNumber *eventTapID = @(tapInfo.eventTapID);
        if (tapInfo.tappingProcess == getpid() && ![beforeTapIDs containsObject:eventTapID]) {
            [afterTapIDs addObject:@(tapInfo.eventTapID)];
        }
    }

    XCTAssertEqual(1, afterTapIDs.count);
    XCTAssertEqual([[afterTapIDs anyObject] unsignedIntValue], tap.eventTapID);
}

- (void)testStartsDisabled {
    WJHEventTap *tap = [self makePassiveTap];
    XCTAssertFalse(tap.isEnabled);
}

- (void)testProcessLocationMeansProcessTap {
    WJHEventTap *tap = [[WJHEventTap alloc] initWithLocation:kWJHProcessEventTap eventMask:kCGEventMaskForAllEvents beforeOthers:YES passive:YES runLoop:nil delegate:delegate];
    XCTAssertEqual(kWJHProcessEventTap, tap.location);

    NSArray *array = [WJHEventTap systemTapsWithTransform:^id(const CGEventTapInformation *tapInfo) {
        return tapInfo->eventTapID == tap.eventTapID ? @(tapInfo->tapPoint) : nil;
    }];
    XCTAssertEqual(1, array.count);
    XCTAssertEqualObjects(@(kWJHProcessEventTap), [array lastObject]);
}

- (void)testInsertingTapBefore {
    NSArray *taps = [self makeTapsBeforeOthers:YES];
    [self expectEventsInOrder:taps];
}

- (void)testInsertingTapAfter {
    NSArray *taps = [self makeTapsBeforeOthers:NO];
    [self expectEventsInOrder:taps];
}

- (void)testRemovalOnDealloc {
    NSSet *origTaps = [NSSet setWithArray:[WJHEventTap systemTapsWithTransform:^id(const CGEventTapInformation *tapInfo) {
        return @(tapInfo->eventTapID);
    }]];

    [self wjh_intervalExpectation:0.05 predicate:^BOOL{
        return [WJHEventTap systemTapCount] == origTaps.count;
    }];

    @autoreleasepool {
        NSMutableArray *myTaps = [NSMutableArray new];
        for (int i = 0; i < 5; ++i) {
            WJHEventTap *tap = [self makePassiveTap];
            [myTaps addObject:tap];
        }
    }

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testObservingIsEnabled {
    WJHEventTap *tap = [self makePassiveTap];
    [self keyValueObservingExpectationForObject:tap keyPath:@"enabled" expectedValue:@YES];
    [self keyValueObservingExpectationForObject:tap keyPath:@"enabled" expectedValue:@NO];
    tap.enabled = YES;
    tap.enabled = NO;
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


#pragma mark - Helpers

- (WJHEventTap*)makeActiveTap {
    return [[WJHEventTap alloc] initWithProcess:nil eventMask:kCGEventMaskForAllEvents beforeOthers:YES passive:NO runLoop:nil delegate:delegate];
}

- (WJHEventTap*)makePassiveTap {
    return [[WJHEventTap alloc] initWithProcess:nil eventMask:kCGEventMaskForAllEvents beforeOthers:YES passive:YES runLoop:nil delegate:delegate];
}

static BOOL getSystemTapsWithCAPI(CGEventTapInformation **tapInfo, uint32_t *length) {
    uint32_t maxCount, count;

    CGGetEventTapList(0, NULL, &maxCount);
    if (maxCount) {
        CGEventTapInformation *info = malloc(sizeof(*info) * maxCount);
        memset(info, 0, sizeof(*info) * maxCount);
        CGError error = CGGetEventTapList(maxCount, info, &count);
        if (error == kCGErrorSuccess) {
            *tapInfo = info;
            *length = count;
            return YES;
        } else {
            *tapInfo = NULL;
            free(info);
        }
    }
    return NO;
}

- (void)postMouseClick:(CGEventType)type button:(CGMouseButton)button toProcess:(ProcessSerialNumber)psn {
    CGEventRef event = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(event);
    CFRelease(event);

    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    event = CGEventCreateMouseEvent(source, type, mouseLocation, button);
    CGEventPostToPSN(&psn, event);
    CFRelease(source);
    CFRelease(event);
}

- (NSArray*)makeTapsBeforeOthers:(BOOL)beforeOthers {
    NSLog(@"Making Taps");
    NSMutableArray *taps = [NSMutableArray new];
    for (int i = 0; i < 5; ++i) {
        WJHEventTap *tap = [[WJHEventTap alloc] initWithProcess:nil eventMask:kCGEventMaskForAllEvents beforeOthers:beforeOthers passive:NO runLoop:nil delegate:delegate];
        if (beforeOthers) {
            [taps insertObject:tap atIndex:0];
        } else {
            [taps addObject:tap];
        }
        tap.enabled = YES;
    }
    return [taps copy];
}

- (void)expectEventsInOrder:(NSArray*)taps {
    NSLog(@"Looking for Events");
    XCTestExpectation *expectation = [self expectationWithDescription:@"Events Received"];
    __block NSUInteger upCount = 0;
    delegate.otherMouseUpEvent = ^CGEventRef(WJHEventTap *eventTap, CGEventRef event, CGEventTapProxy proxy) {
        if (upCount < taps.count && eventTap == taps[upCount]) {
            if (++upCount == taps.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [expectation fulfill];
                });
                //delegate.otherMouseUpEvent = nil;
                event = nil;
            }
        }
        return event;
    };

    ProcessSerialNumber psn = [[taps lastObject] processSerialNumber];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Posting Events");
        [self postMouseClick:kCGEventOtherMouseDown button:31 toProcess:psn];
        [self postMouseClick:kCGEventOtherMouseUp button:31 toProcess:psn];
        NSLog(@"Done Posting Events");
    });

    NSLog(@"Waiting");
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end


