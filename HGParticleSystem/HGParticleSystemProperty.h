//
//  HGParticleSystemProperty.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 09/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"
#import "HGLookupTable.h"
#import "HGParticleSystemKeys.h"

#ifndef HGPSPR_
#define HGPSPR_

typedef const struct _HGPropertyRef * HGPropertyRef;

// parses the (human-readable) value stored in a .hgps file
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithDictionary(const CFDictionaryRef dictionary);
FOUNDATION_EXPORT HGParticleSystemPropertyOption HGParticleSystemPropertyOptionFromString (NSString *string);

FOUNDATION_EXPORT void HGPropertyRelease(HGPropertyRef property);
FOUNDATION_EXPORT HGFloat HGPropertyGetFloatValue(HGPropertyRef property, const HGFloat t);
FOUNDATION_EXPORT GLKVector3 HGPropertyGetGLKVector3Value(HGPropertyRef property, const HGFloat t);
FOUNDATION_EXPORT HGParticleSystemPropertyOption HGPropertyGetOption(HGPropertyRef property);

// public creation functions
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithConstant(const HGFloat constant);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithRandomConstants(const HGFloat constant1, const HGFloat constant2);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithCurve(const HGLookupTableRef lut);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColor(HGColor *color);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithRandomColor(HGColor *color1, HGColor *color2);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColorRandomRGB(const HGFloat r1, const HGFloat r2, const HGFloat g1, const HGFloat g2, const HGFloat b1, const HGFloat b2);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColorRandomHSV(const HGFloat h1, const HGFloat h2, const HGFloat s1, const HGFloat s2, const HGFloat v1, const HGFloat v2);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithGradient(const HGLookupTableRef lut);

// these are used purely for internal mechanics
FOUNDATION_EXPORT CFDictionaryRef HGPropertyCreateDictionaryRepresentation(HGPropertyRef property);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithDictionaryRepresentation(const CFDictionaryRef dictionary);

#endif
