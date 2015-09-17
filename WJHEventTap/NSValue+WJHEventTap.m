//
//  NSValue+WJHEventTap.m
//  WJHEventTap
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "NSValue+WJHEventTap.h"

@implementation NSValue (WJHEventTap)

+ (NSValue*)wjh_valueWithCGEventTapInformation:(CGEventTapInformation)tapInfo {
    return [NSValue valueWithBytes:&tapInfo objCType:@encode(CGEventTapInformation)];
}

- (CGEventTapInformation)wjh_CGEventTapInformationValue {
    CGEventTapInformation tapInfo;
    [self getValue:&tapInfo];
    return tapInfo;
}

@end
