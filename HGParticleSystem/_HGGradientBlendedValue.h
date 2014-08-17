//
//  _HGGradientBlendedValue.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"

@protocol _HGGradientBlendedValue <NSCopying>

- (id)blendedValueWithFraction:(CGFloat)fraction ofValue:(id)value;

@end

@interface NSNumber (Blended) <_HGGradientBlendedValue>
@end

@interface HGColor (Blended) <_HGGradientBlendedValue>
@end

