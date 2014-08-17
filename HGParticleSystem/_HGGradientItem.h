//
//  _HGGradientItem.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_HGGradientBlendedValue.h"

@interface _HGGradientItem : NSObject <NSCopying>

@property (nonatomic) NSNumber *location;
@property (nonatomic) id<_HGGradientBlendedValue> value;

+ (instancetype)itemWithLocation:(CGFloat)location value:(id<_HGGradientBlendedValue>)value;

@end