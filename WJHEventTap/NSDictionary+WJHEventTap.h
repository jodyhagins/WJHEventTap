//
//  NSDictionary+WJHEventTap.h
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WJHEventTap)

/**
 Creates a dictionary object containing the specified CGEventTapInformation structure.

 @param tapInfo the value for the new object

 @return A new dictionary object that contains the @a tapInfo information.

 Each field of the structure is contained in the dictionary, with the same name as in the actual structure.  Each value is wrapped in an NSNumber object, as appropriate for the field value type.
 */
+ (NSDictionary*)wjh_dictionaryWithCGEventTapInformation:(CGEventTapInformation)tapInfo;

/**
 The CGEventTapInformation structure representation of the value.  Any field not found in the dictionary will be set to zero.
 */
@property (readonly) CGEventTapInformation wjh_CGEventTapInformationValue;

@end
