//
//  HGParticleSystemProperty.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 09/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"
#import "HGParticleSystemKeys.h"

#ifndef HGPSPR_
#define HGPSPR_

typedef const struct _HGPropertyRef * HGPropertyRef;

FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithDictionary(const CFDictionaryRef dictionary);
FOUNDATION_EXPORT void HGPropertyRelease(HGPropertyRef property);
FOUNDATION_EXPORT HGFloat HGPropertyGetFloatValue(HGPropertyRef property, const HGFloat t);
FOUNDATION_EXPORT GLKVector3 HGPropertyGetGLKVector3Value(HGPropertyRef property, const HGFloat t);
FOUNDATION_EXPORT HGParticleSystemPropertyOption HGPropertyGetOption(HGPropertyRef property);
    
FOUNDATION_EXPORT CFDictionaryRef HGPropertyCreateDictionaryRepresentation(HGPropertyRef property);
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithDictionaryRepresentation(const CFDictionaryRef dictionary);

#endif
