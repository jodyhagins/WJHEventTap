//
//  WJHEventTapDelegate.h
//  WJHEventTap
//
//  Created by Jody Hagins on 9/17/15.
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WJHEventTap;

#pragma mark - WJHEventTapDelegate Protocol

/**
 Protocol to be implemented by any WJHEventTap delegate
 */
@protocol WJHEventTapDelegate<NSObject>
@optional

/**
 Called when any event is received by the tap, this method will be called before any other delegate method for any given event.

 @param eventTap the tap for which the event is being processed
 @param event a pointer to the intercepted event, guaranteed to not be NULL.  The dereferenced object is the incoming event, owned by the caller, and does not need to be released.
 @param type the type of event that was intercepted
 @param proxy the tap proxy

 @return YES if processing for this event is complete.  In that case, *event will be returned to the system event processor and no other delegate methods are called for this event.  NO if event-specific delegate methods should be called.

 @note The following rules apply for all event processing delegate methods.  If the eventTap is active, one of the following values should be returned:

 - The same event that was passed in.  The system event processor will continue using the event, releasing it when complete.

 - A newly-constructed event.  The system event processor will use the returned event for further event handling.  When done, the system event processor will release both the original incoming event and the new event returned to it.

 - NULL to have the system event processor delete (and stop further processing of) the event.  The system will still be responsible for releasing the incoming event.
 */
- (BOOL)eventTap:(WJHEventTap*)eventTap receivedEvent:(CGEventRef*)event type:(CGEventType)type proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventNull is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap nullEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventLeftMouseDown is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap leftMouseDownEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventLeftMouseDragged is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap leftMouseDraggedEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventLeftMouseUp is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap leftMouseUpEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventRightMouseDown is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap rightMouseDownEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventRightMouseDragged is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap rightMouseDraggedEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventRightMouseUp is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap rightMouseUpEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventOtherMouseDown is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap otherMouseDownEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventOtherMouseDragged is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap otherMouseDraggedEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventOtherMouseUp is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap otherMouseUpEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventMouseMoved is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap mouseMovedEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventKeyDown is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap keyDownEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventKeyUp is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap keyUpEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventFlagsChanged is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap modifierFlagsChangedEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventScrollWheel is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap scrollWheelEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventTabletPointer is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap tabletPointerEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventTabletProximity is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap tabletProximityEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventTapDisabledByTimeout is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap eventTapDisabledByTimeoutEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when a kCGEventTapDisabledByUserInput is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap eventTapDisabledByUserInputEvent:(CGEventRef)event proxy:(CGEventTapProxy)proxy;

/**
 Called when an unknown event type is received by the tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param type the type of the unknown event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
- (CGEventRef)eventTap:(WJHEventTap*)eventTap unknownEvent:(CGEventRef)event type:(CGEventType)type proxy:(CGEventTapProxy)proxy;

@end


#pragma mark - WJHEventTapDelegate Class

/**
 Block for handling any event from an event tap.

 @param eventTap the tap for which the event is being processed
 @param event a pointer to the intercepted event, guaranteed to not be NULL.  The dereferenced object is the incoming event, owned by the caller, and does not need to be released.
 @param type the type of event that was intercepted
 @param proxy the tap proxy

 @return YES if processing for this event is complete.  In that case, *event will be returned to the system event processor.  NO if event-specific delegate methods should be called.
 */
typedef BOOL (^WJHEventTapReceivedEventBlock)(WJHEventTap *eventTap, CGEventRef *event, CGEventType type, CGEventTapProxy proxy);

/**
 Block for handling known events from an event tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
typedef CGEventRef (^WJHEventTapEventBlock)(WJHEventTap *eventTap, CGEventRef event, CGEventTapProxy proxy);

/**
 Block for handling an unknown event from an event tap.

 @param eventTap the tap for which the event is being processed
 @param event the intercepted event
 @param type the type of the unknown event
 @param proxy the tap proxy

 @return the event as it is to be interpreted by the system event processor.
 */
typedef CGEventRef (^WJHEventTapUnknownEventBlock)(WJHEventTap *eventTap, CGEventRef event, CGEventType type, CGEventTapProxy proxy);

/**
 A concrete class that implements all delegate methods of the @a WJHEventTapDelegate protocol by forwarding the call to the similarly named block property.

 If the event handler block is nil, the resulting behavior is the same as if the delegate method had not been overridden.

 Otherwise, the delegate method forwards the call to the block, and returns the return value of the block.
 */
@interface WJHEventTapDelegate : NSObject<WJHEventTapDelegate>

@property (strong) WJHEventTapReceivedEventBlock receivedEvent;
@property (strong) WJHEventTapEventBlock nullEvent;
@property (strong) WJHEventTapEventBlock leftMouseDownEvent;
@property (strong) WJHEventTapEventBlock leftMouseDraggedEvent;
@property (strong) WJHEventTapEventBlock leftMouseUpEvent;
@property (strong) WJHEventTapEventBlock rightMouseDownEvent;
@property (strong) WJHEventTapEventBlock rightMouseDraggedEvent;
@property (strong) WJHEventTapEventBlock rightMouseUpEvent;
@property (strong) WJHEventTapEventBlock otherMouseDownEvent;
@property (strong) WJHEventTapEventBlock otherMouseDraggedEvent;
@property (strong) WJHEventTapEventBlock otherMouseUpEvent;
@property (strong) WJHEventTapEventBlock mouseMovedEvent;
@property (strong) WJHEventTapEventBlock keyDownEvent;
@property (strong) WJHEventTapEventBlock keyUpEvent;
@property (strong) WJHEventTapEventBlock modifierFlagsChangedEvent;
@property (strong) WJHEventTapEventBlock scrollWheelEvent;
@property (strong) WJHEventTapEventBlock tabletPointerEvent;
@property (strong) WJHEventTapEventBlock tabletProximityEvent;
@property (strong) WJHEventTapEventBlock eventTapDisabledByTimeoutEvent;
@property (strong) WJHEventTapEventBlock eventTapDisabledByUserInputEvent;
@property (strong) WJHEventTapUnknownEventBlock unknownEvent;

@end
