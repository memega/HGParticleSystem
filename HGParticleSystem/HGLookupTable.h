//
//  HGLookupTable.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 10/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "HGTypes.h"

#ifndef HGLUT_
#define HGLUT_

typedef const struct _HGLookupTableRef * HGLookupTableRef;

FOUNDATION_EXPORT HGLookupTableRef HGLookupTableMakeWithFloat(const HGFloat *values, const size_t size, const HGFloat min, const HGFloat max);
FOUNDATION_EXPORT HGLookupTableRef HGLookupTableMakeWithGLKVector4(const GLKVector4 *values, const size_t size);
FOUNDATION_EXPORT void HGLookupTableRelease(HGLookupTableRef lut);
FOUNDATION_EXPORT HGFloat HGLookupTableGetCGFloatValue(HGLookupTableRef lut, const HGFloat t);
FOUNDATION_EXPORT GLKVector3 HGLookupTableGetGLKVector3Value(HGLookupTableRef lut, const HGFloat t);
FOUNDATION_EXPORT GLKVector4 HGLookupTableGetGLKVector4Value(HGLookupTableRef lut, const HGFloat t);

FOUNDATION_EXPORT CFDictionaryRef HGLookupTableCreateDictionaryRepresentation(HGLookupTableRef lut);
FOUNDATION_EXPORT HGLookupTableRef HGLookupTableMakeWithDictionaryRepresentation(CFDictionaryRef dictionary);

#endif
