//
//  HGTypes.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#ifndef HGParticleEditor_HGFloat_h
#define HGParticleEditor_HGFloat_h

#define USE_LOOKUP_CGFLOAT 0

#if USE_LOOKUP_CGFLOAT
#define HGFloat CGFloat
#else
#define HGFloat GLfloat
#endif

// color
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define HGColor UIColor
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define HGColor NSColor
#endif

// rect
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define HGRect CGRect
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define HGRect NSRect
#endif

// insets
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define HGEdgeInsets UIEdgeInsets
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define HGEdgeInsets NSEdgeInsets
#endif

static inline HGFloat HGFloatLerp(HGFloat a, HGFloat b, HGFloat ratio)
{
    return (b - a) * ratio + a;
}

FOUNDATION_EXPORT GLKVector4 const HGGLKVector4None;
FOUNDATION_EXPORT GLKVector2 const HGGLKVector2None;
FOUNDATION_EXPORT GLKVector4 const HGGLKVector4Zero;
FOUNDATION_EXPORT GLKVector2 const HGGLKVector2Zero;

FOUNDATION_EXPORT GLKVector4 HGGLKVector4MakeWithColor(HGColor *color);

#endif
