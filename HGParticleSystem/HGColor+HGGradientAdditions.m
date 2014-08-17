//
//  NSColor+HGGradientAdditions.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGColor+HGGradientAdditions.h"

@implementation HGColor (HGGradientAdditions)

- (NSString *)hg_hexDescription
{
    CGFloat components[4];
    [self getRed:components green:components+1 blue:components+2 alpha:components+3];
    uint8_t r = components[0] * 255;
    uint8_t g = components[1] * 255;
    uint8_t b = components[2] * 255;
    uint8_t a = components[3] * 255;
    
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X", r, g, b, a];
}

- (NSString *)hg_hexDescriptionWithoutAlpha
{
    CGFloat components[3];
    [self getRed:components green:components+1 blue:components+2 alpha:NULL];
    uint8_t r = components[0] * 255;
    uint8_t g = components[1] * 255;
    uint8_t b = components[2] * 255;
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
}

- (CGFloat)hg_alphaComponent
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CGFloat alpha;
    [self getRed:NULL green:NULL blue:NULL alpha:&alpha];
    return alpha;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    return [self alphaComponent];
#endif
}

@end
