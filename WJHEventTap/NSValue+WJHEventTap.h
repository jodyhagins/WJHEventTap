//
//  NSValue+WJHEventTap.h
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (WJHEventTap)

/**
 Creates a value object containing the specified CGEventTapInformation structure.

 @param tapInfo the value for the new object

 @return A new value object that contains the @a tapInfo information.
 */
+ (NSValue*)wjh_valueWithCGEventTapInformation:(CGEventTapInformation)tapInfo;

/**
 The CGEventTapInformation structure representation of the value.
 */
@property (readonly) CGEventTapInformation wjh_CGEventTapInformationValue;

@end
