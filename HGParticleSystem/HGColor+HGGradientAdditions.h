//
//  NSColor+HGGradientAdditions.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"

@interface HGColor (HGGradientAdditions)

- (NSString *)hg_hexDescription;
- (NSString *)hg_hexDescriptionWithoutAlpha;

- (CGFloat)hg_alphaComponent;

@end
