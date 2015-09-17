//
//  WJHEventTap.h
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//


//FOUNDATION_EXPORT double WJHEventTapVersionNumber;
//FOUNDATION_EXPORT const unsigned char WJHEventTapVersionString[];


#import <Foundation/Foundation.h>
#import <WJHEventTap/WJHEventTapDelegate.h>
#import <WJHEventTap/NSDictionary+WJHEventTap.h>
#import <WJHEventTap/NSValue+WJHEventTap.h>

enum {
    /// The location value that will be returned as the "tapPoint" field of CGEventTapInformation and the "location" property of WJHEventTap if the represented event tap is targetd at a specific process instead of one of the general tap locations.
    kWJHProcessEventTap = 3,
};


#pragma mark - WJHEventTap

/**
 Allow a little easier management of event taps than the CGEventTap API.
 */
@interface WJHEventTap : NSObject

/**
 Get the total number of all system event taps.

 This number includes all taps, including, but not limited to WJHEventTap style taps.
 */
+ (uint32_t)systemTapCount;

/**
 Get all system taps.

 @return an array of NSValue-boxed CGEventTapInformation structures, each representing a system tap.
 */
+ (NSArray*)systemTaps;

/**
 Get an array of objects by applying the transform to each system tap.

 @param transform a block that transforms a CGEventTapInformation structure into an ObjectiveC object.  If @a transform is nil, the structures will be converted into NSValue-boxed objects.  The pointer passed into @a transform is guaranteed to be non-NULL.

 @return an array of objects representing each currently installed system tap.  Each object is the result of applying @a transform on each system tap.

 @note Return nil from the transform block if you want the resulting array to exclude that item.

 @code
 NSArray *eventTapIDs = [WJHEventTap systemTapsWithTransform:^id(const CGEventTapInformation *tapInfo) {
     return @(tapInfo->eventTapID);
 }];
 @endCode
 */
+ (NSArray *)systemTapsWithTransform:(id(^)(CGEventTapInformation const *tapInfo))transform;

/**
 The runLoop to which the tap is attached.
 */
@property (nonatomic, strong, readonly) NSRunLoop *runLoop;

/**
 The actual event mask used to create the event tap.

 When an event tap is created, it takes the requested mask, and strips off the bits that can't be supported (e.g., requesting keyboard events without accessibility authorization).  Thus, this value may be different from the actual requested event bitmask.
 */
@property (nonatomic, assign, readonly) CGEventMask eventMask;

/**
 The event mask as requested in the initializer.
 */
@property (nonatomic, assign, readonly) CGEventMask requestedEventMask;

/**
 Whether the tap was inserted before other taps, or after other taps.
 */
@property (nonatomic, assign, readonly) BOOL beforeOthers;

/**
 Whether the tap was created in passive or active mode.
 */
@property (nonatomic, assign, readonly) BOOL passive;

/**
 The enabled/disabled state of the tap.
 */
@property (atomic, assign, getter=isEnabled) BOOL enabled;

/**
 The unique event tap ID
 */
@property (nonatomic, assign, readonly) uint32_t eventTapID;

/**
 The location of the event tap.

 If the receiver was initialized with a tap location, the returned value will be the same value as passed to the initializer.

 If the receiver was initialized by targeting a specific process, the returned value will be equal to kWJHProcessEventTap.
 */
@property (nonatomic, assign, readonly) CGEventTapLocation location;

/**
 The serial number of the process targeted by this event tap.

 If the event tap is targeted at a specific process, the returned value will be the same value as poassed into the initializer.

 If the event tap is not targeted at a specific process, this structure will contain all zero-bytes.
 */
@property (nonatomic, assign, readonly) ProcessSerialNumber processSerialNumber;

/**
 The tap delegate, which will be notified for any action on the tap.

 @note The delegate is held strongly by the tap.  The delegate can be changed, and set to nil.
 */
@property (atomic, strong) id<WJHEventTapDelegate> delegate;

/**
 Initialize an event tap

 @param location specifies at what point in event processing the tap is to be inserted.  If @a location is equal to kWJHProcessEventTap, then the tap will be installed at the currently running process.
 @param eventMask a bitmask that specifies which events are to be intercepted
 @param beforeOthers YES means that the tap will be inserted before any existing taps at the same location.  NO means that the tap will be inserted after any existing taps at the same location.
 @param passive YES for a passive (listen only) tap, NO for an active tap that can change the event being processed.
 @param runLoop the run loop to which this tap will be attached.  The tap will be added to the run loop for all common run loop modes.
 @param delegate the delegate to be notified of tap events.

 @note The event tap is created in a disabled state, and must be manually enabled.

 @see CGEventTapCreate in Apple's API
 */
- (instancetype)initWithLocation:(CGEventTapLocation)location eventMask:(CGEventMask)eventMask beforeOthers:(BOOL)beforeOthers passive:(BOOL)passive runLoop:(NSRunLoop *)runLoop delegate:(id<WJHEventTapDelegate>)delegate;

/**
 Initialize an event tap

 @param process a pointer to serial number for the process to be tapped, or NULL for the current process.
 @param eventMask a bitmask that specifies which events are to be intercepted
 @param beforeOthers YES means that the tap will be inserted before any existing taps at the same location.  NO means that the tap will be inserted after any existing taps at the same location.
 @param passive YES for a passive (listen only) tap, NO for an active tap that can change the event being processed.
 @param runLoop the run loop to which this tap will be attached.  The tap will be added to the run loop for all common run loop modes.
 @param delegate the delegate to be notified of tap events.

 @note The event tap is created in a disabled state, and must be manually enabled.

 @see CGEventTapCreate in Apple's API
 */
- (instancetype)initWithProcess:(ProcessSerialNumber*)process eventMask:(CGEventMask)eventMask beforeOthers:(BOOL)beforeOthers passive:(BOOL)passive runLoop:(NSRunLoop *)runLoop delegate:(id<WJHEventTapDelegate>)delegate;

@end
