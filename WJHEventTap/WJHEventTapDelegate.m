//
//  WJHEventTapDelegate.m
//  WJHEventTap
//
//  Created by Jody Hagins on 9/17/15.
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHEventTapDelegate.h"

@implementation WJHEventTapDelegate

- (BOOL)eventTap:(WJHEventTap*)eventTap receivedEvent:(CGEventRef*)event type:(CGEventType)type proxy:(CGEventTapProxy)proxy {
    return self.receivedEvent ? self.receivedEvent(eventTap, event, type, proxy) : NO;
}
- (CGEventRef)eventTap:(WJHEventTap*)eventTap unknownEvent:(CGEventRef)event type:(CGEventType)type proxy:(CGEventTapProxy)proxy {
    return self.unknownEvent ? self.unknownEvent(eventTap, event, type, proxy) : event;
}

#define EventHandler(_name_) \
- (CGEventRef)eventTap:(WJHEventTap*)eventTap _name_:(CGEventRef)event proxy:(CGEventTapProxy)proxy { \
return self._name_ ? self._name_(eventTap, event, proxy) : event; \
}
EventHandler(nullEvent);
EventHandler(leftMouseDownEvent);
EventHandler(leftMouseDraggedEvent);
EventHandler(leftMouseUpEvent);
EventHandler(rightMouseDownEvent);
EventHandler(rightMouseDraggedEvent);
EventHandler(rightMouseUpEvent);
EventHandler(otherMouseDownEvent);
EventHandler(otherMouseDraggedEvent);
EventHandler(otherMouseUpEvent);
EventHandler(mouseMovedEvent);
EventHandler(keyDownEvent);
EventHandler(keyUpEvent);
EventHandler(modifierFlagsChangedEvent);
EventHandler(scrollWheelEvent);
EventHandler(tabletPointerEvent);
EventHandler(tabletProximityEvent);
EventHandler(eventTapDisabledByTimeoutEvent);
EventHandler(eventTapDisabledByUserInputEvent);
#undef EventHandler

@end
