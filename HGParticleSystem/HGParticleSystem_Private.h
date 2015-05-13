//
//  HGParticleSystem_Private.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 12/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

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

