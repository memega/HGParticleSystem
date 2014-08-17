//
//  NSColor+Serialization.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGColor+Serialization.h"

#import "HGAssert.h"
#import "CGFloatAdditions.h"

@implementation HGColor (Serialization)

+ (instancetype)hg_colorWithDictionary:(NSDictionary *)dictionary
{
    HGAssert(dictionary, @"NSColor: nil dictionary");
    
    CGFloat redComponent = [dictionary hg_CGFloatForKey:@"redComponent"];
    HGAssert(!isnan(redComponent), @"NSColor: NAN redComponent");
    
    CGFloat greenComponent = [dictionary hg_CGFloatForKey:@"greenComponent"];
    HGAssert(!isnan(greenComponent), @"NSColor: NAN greenComponent");
    
    CGFloat blueComponent = [dictionary hg_CGFloatForKey:@"blueComponent"];
    HGAssert(!isnan(blueComponent), @"NSColor: NAN blueComponent");
    
    CGFloat alphaComponent = [dictionary hg_CGFloatForKey:@"alphaComponent"];
    HGAssert(!isnan(alphaComponent), @"NSColor: NAN alphaComponent");
    
    return [HGColor colorWithRed:redComponent
                           green:greenComponent
                            blue:blueComponent
                           alpha:alphaComponent];
}

- (NSDictionary *)hg_dictionary
{
    CGFloat red, blue, green, alpha;
    [self getRed:&red green:&blue blue:&green alpha:&alpha];
    return @{
             @"valueClass": @"NSColor",
             @"redComponent": @(red),
             @"greenComponent": @(green),
             @"blueComponent": @(blue),
             @"alphaComponent": @(alpha),
             };
}

@end
