//
//  HGTypes.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGTypes.h"

GLKVector4 const HGGLKVector4None = (GLKVector4){FLT_MAX,FLT_MAX,FLT_MAX,FLT_MAX};
GLKVector2 const HGGLKVector2None = (GLKVector2){FLT_MAX,FLT_MAX};
GLKVector4 const HGGLKVector4Zero = (GLKVector4){0.f, 0.f, 0.f, 0.f};
GLKVector2 const HGGLKVector2Zero = (GLKVector2){0.f, 0.f};

GLKVector4 HGGLKVector4MakeWithColor(HGColor *color)
{
    CGFloat components[4];
    [color getRed:components green:components+1 blue:components+2 alpha:components+3];
    return GLKVector4Make(components[0], components[1], components[2], components[3]);
}

