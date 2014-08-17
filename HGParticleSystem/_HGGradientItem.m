//
//  _HGGradientItem.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "_HGGradientItem.h"

#import "CGFloatAdditions.h"

#pragma mark - _HGGradientItem

@implementation _HGGradientItem

+ (instancetype)itemWithLocation:(CGFloat)location value:(id<_HGGradientBlendedValue>)value
{
    return [[self alloc] initWithLocation:location value:value];
}

- (instancetype)initWithLocation:(CGFloat)location value:(id<_HGGradientBlendedValue>)value
{
    self = [super init];
    if (self) {
        self.location = @(location);
        self.value = value;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithLocation:[self.location hg_CGFloatValue] value:[self.value copyWithZone:zone]];
}

@end
