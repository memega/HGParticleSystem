//
//  _HGGradientBlendedValue.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "_HGGradientBlendedValue.h"

#import "CGFloatAdditions.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface UIColor (HGTypes)
-(instancetype)hg_blendedColorWithFraction:(CGFloat)fraction ofColor:(UIColor *)color;
@end

@implementation UIColor (HGTypes)

-(instancetype)hg_blendedColorWithFraction:(CGFloat)fraction ofColor:(UIColor *)color
{
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;
    
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat p = fraction, q = 1.0 - p,
    r = r1 * q + r2 * p,
    g = g1 * q + g2 * p,
    b = b1 * q + b2 * p,
    a = a1 * q + a2 * p;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface NSColor (HGTypes)
-(instancetype)hg_blendedColorWithFraction:(CGFloat)fraction ofColor:(NSColor *)color;
@end

@implementation NSColor (HGTypes)

-(instancetype)hg_blendedColorWithFraction:(CGFloat)fraction ofColor:(NSColor *)color
{
    return [self blendedColorWithFraction:fraction ofColor:color];
}

@end
#endif

@implementation NSNumber (Blended)

- (id)blendedValueWithFraction:(CGFloat)fraction ofValue:(id)value
{
    NSNumber *number2 = value;
    CGFloat n1 = [self hg_CGFloatValue];
    CGFloat n2 = [number2 hg_CGFloatValue];
    return @(n1 + (n2 - n1) * fraction);
}

@end

@implementation HGColor (Blended)

- (id)blendedValueWithFraction:(CGFloat)fraction ofValue:(id)value
{
    return [self hg_blendedColorWithFraction:fraction ofColor:value];
}

@end