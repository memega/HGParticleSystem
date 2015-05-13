//
//  HGLookupTable_Private.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 12/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT CFDictionaryRef _HGLookupTableCreateDictionaryRepresentation(HGLookupTableRef lut);
FOUNDATION_EXPORT HGLookupTableRef _HGLookupTableMakeWithDictionaryRepresentation(CFDictionaryRef dictionary);
