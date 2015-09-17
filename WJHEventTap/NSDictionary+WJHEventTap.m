//
//  NSDictionary+WJHEventTap.m
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "NSDictionary+WJHEventTap.h"

@implementation NSDictionary (WJHEventTap)

#define insert(_name_) @#_name_ : @(tapInfo._name_)
#define insertType(_name_, _type_) @#_name_ : @((_type_)tapInfo._name_)
+ (NSDictionary*)wjh_dictionaryWithCGEventTapInformation:(CGEventTapInformation)tapInfo {
    return @{insert(eventTapID),
             insert(tapPoint),
             insert(options),
             insert(eventsOfInterest),
             insert(tappingProcess),
             insert(processBeingTapped),
             insertType(enabled, BOOL),
             insert(minUsecLatency),
             insert(avgUsecLatency),
             insert(maxUsecLatency),
             };
}

#define extract(_name_, _valtype_) tapInfo._name_ = [self[@#_name_] _valtype_]
- (CGEventTapInformation)wjh_CGEventTapInformationValue {
    CGEventTapInformation tapInfo;
    extract(eventTapID, unsignedIntValue);
    extract(tapPoint, unsignedIntValue);
    extract(options, unsignedIntValue);
    extract(eventsOfInterest, unsignedLongValue);
    extract(tappingProcess, intValue);
    extract(processBeingTapped, intValue);
    extract(enabled, boolValue);
    extract(minUsecLatency, floatValue);
    extract(avgUsecLatency, floatValue);
    extract(maxUsecLatency, floatValue);
    return tapInfo;
}

@end