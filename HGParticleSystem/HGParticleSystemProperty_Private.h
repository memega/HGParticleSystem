//
//  HGParticleSystemProperty_Private.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 12/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

// parses a human-readable value stored in a .hgps file
FOUNDATION_EXPORT HGPropertyRef _HGPropertyMakeWithDictionary(const CFDictionaryRef dictionary);
FOUNDATION_EXPORT HGParticleSystemPropertyOption _HGParticleSystemPropertyOptionFromString (NSString *string);

// these are used purely for internal mechanics
FOUNDATION_EXPORT CFDictionaryRef _HGPropertyCreateDictionaryRepresentation(HGPropertyRef property);
FOUNDATION_EXPORT HGPropertyRef _HGPropertyMakeWithDictionaryRepresentation(const CFDictionaryRef dictionary);