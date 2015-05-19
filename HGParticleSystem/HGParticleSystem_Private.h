/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

#pragma mark - Texture modes

/**
 *  Texture module. Used only for .hgps editing.
 */
FOUNDATION_EXPORT NSString * const _HGTextureModulePropertyKey;
FOUNDATION_EXPORT NSString * const _HGTextureModePropertyKey;
FOUNDATION_EXPORT NSString * const _HGTextureFilePropertyKey;
FOUNDATION_EXPORT NSString * const _HGTextureSpriteFrameSourcePropertyKey;
FOUNDATION_EXPORT NSString * const _HGTextureSpriteFramePropertyKey;
FOUNDATION_EXPORT NSString * const _HGTexturePropertyKey;

#pragma mark - Texture Mode options

FOUNDATION_EXPORT NSString * const _HGTextureModeEmbedded;
FOUNDATION_EXPORT NSString * const _HGTextureModeFile;
FOUNDATION_EXPORT NSString * const _HGTextureModeSpriteFrame;

typedef NS_ENUM(NSInteger, _HGParticleSystemTextureMode){
    _HGParticleSystemTextureModeEmbedded = 0,
    _HGParticleSystemTextureModeFile = 1,
    _HGParticleSystemTextureModeSpriteFrame = 2,
    _HGParticleSystemTextureModeUndefined = NSNotFound,
};

#pragma mark - Shape options

FOUNDATION_EXPORT NSString * const _HGParticleSystemEmitterShapeSectorValue;
FOUNDATION_EXPORT NSString * const _HGParticleSystemEmitterShapeCircleValue;
FOUNDATION_EXPORT NSString * const _HGParticleSystemEmitterShapeOvalValue;
FOUNDATION_EXPORT NSString * const _HGParticleSystemEmitterShapeRectValue;

#pragma mark - Speed acceleration options

FOUNDATION_EXPORT NSString * const _HGParticleSystemSpeedCurve;
FOUNDATION_EXPORT NSString * const _HGParticleSystemSpeedAcceleration;

#pragma mark - Rotation options

FOUNDATION_EXPORT NSString * const _HGParticleSystemRotationVelocity;
FOUNDATION_EXPORT NSString * const _HGParticleSystemRotationFollow;

#pragma mark - GL Blending Modes

FOUNDATION_EXPORT NSString * const _HGBlendModeGlZero;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOne;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlSrcColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusSrcColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlDstColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusDstColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlSrcAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusSrcAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlDstAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusDstAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlConstantColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusConstantColor;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlConstantAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlOneMinusConstantAlpha;
FOUNDATION_EXPORT NSString * const _HGBlendModeGlSrcAlphaSaturate;

#pragma mark - Value Options

FOUNDATION_EXPORT NSString *_HGStringFromBlendingMode (GLuint blendingMode);
FOUNDATION_EXPORT GLuint _HGBlendingModeFromString (NSString *string);

