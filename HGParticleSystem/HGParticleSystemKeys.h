//
//  HGParticleSystemKeys.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#pragma mark - Property keys

FOUNDATION_EXPORT NSString * const HGMaxParticlesPropertyKey;
FOUNDATION_EXPORT NSString * const HGDurationPropertyKey;
FOUNDATION_EXPORT NSString * const HGLoopingPropertyKey;
FOUNDATION_EXPORT NSString * const HGLifetimePropertyKey;
FOUNDATION_EXPORT NSString * const HGStartSizePropertyKey;
FOUNDATION_EXPORT NSString * const HGStartSpeedPropertyKey;
FOUNDATION_EXPORT NSString * const HGGravityPropertyKey;
FOUNDATION_EXPORT NSString * const HGStartRotationPropertyKey;
FOUNDATION_EXPORT NSString * const HGStartColorPropertyKey;
FOUNDATION_EXPORT NSString * const HGStartOpacityPropertyKey;

FOUNDATION_EXPORT NSString * const HGEmissionModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGEmissionRatePropertyKey;

FOUNDATION_EXPORT NSString * const HGEmitterShapeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapePropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeRadiusPropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeAnglePropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeDirectionPropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeBoundaryPropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeWidthPropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeHeightPropertyKey;
FOUNDATION_EXPORT NSString * const HGEmitterShapeRandomDirectionPropertyKey;

FOUNDATION_EXPORT NSString * const HGEmitterShapeVerticalRatioPropertyKey;

FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimePropertyKey;

FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeRadialAccelerationPropertyKey;
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeTangentialAccelerationPropertyKey;

FOUNDATION_EXPORT NSString * const HGSizeOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGSizeOverLifetimePropertyKey;

FOUNDATION_EXPORT NSString * const HGRotationOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGRotationOverLifetimeModePropertyKey;
FOUNDATION_EXPORT NSString * const HGRotationAngularVelocityPropertyKey;
FOUNDATION_EXPORT NSString * const HGRotationRandomDirectionPropertyKey;

FOUNDATION_EXPORT NSString * const HGSpinningOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGSpinningOverLifetimeAngularVelocityPropertyKey;

FOUNDATION_EXPORT NSString * const HGColorOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGColorOverLifetimePropertyKey;

FOUNDATION_EXPORT NSString * const HGOpacityOverLifetimeModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGOpacityOverLifetimePropertyKey;

FOUNDATION_EXPORT NSString * const HGBlendModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGBlendingSrcPropertyKey;
FOUNDATION_EXPORT NSString * const HGBlendingDstPropertyKey;

FOUNDATION_EXPORT NSString * const HGTextureModulePropertyKey;
FOUNDATION_EXPORT NSString * const HGTextureModePropertyKey;
FOUNDATION_EXPORT NSString * const HGTextureFilePropertyKey;
FOUNDATION_EXPORT NSString * const HGTextureSpriteFrameSourcePropertyKey;
FOUNDATION_EXPORT NSString * const HGTextureSpriteFramePropertyKey;
FOUNDATION_EXPORT NSString * const HGTexturePropertyKey;

#pragma mark - Dynamic options

FOUNDATION_EXPORT NSString * const HGPropertyValueOptionConstant;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionCurve;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomConstants;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomCurve;

FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColor;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColorRandomRGB;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColorRandomHSV;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionGradient;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomColors;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomGradients;

#pragma mark - Shape options

FOUNDATION_EXPORT NSString * const HGParticleSystemEmitterShapeSectorValue;
FOUNDATION_EXPORT NSString * const HGParticleSystemEmitterShapeCircleValue;
FOUNDATION_EXPORT NSString * const HGParticleSystemEmitterShapeOvalValue;
FOUNDATION_EXPORT NSString * const HGParticleSystemEmitterShapeRectValue;

#pragma mark - Speed acceleration options

FOUNDATION_EXPORT NSString * const HGParticleSystemSpeedCurve;
FOUNDATION_EXPORT NSString * const HGParticleSystemSpeedAcceleration;

#pragma mark - Rotation options

FOUNDATION_EXPORT NSString * const HGParticleSystemRotationVelocity;
FOUNDATION_EXPORT NSString * const HGParticleSystemRotationFollow;

#pragma mark - Texture Mode options

FOUNDATION_EXPORT NSString * const HGTextureModeEmbedded;
FOUNDATION_EXPORT NSString * const HGTextureModeFile;
FOUNDATION_EXPORT NSString * const HGTextureModeSpriteFrame;

#pragma mark - GL Blending Modes

FOUNDATION_EXPORT NSString * const HGBlendModeGlZero;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOne;
FOUNDATION_EXPORT NSString * const HGBlendModeGlSrcColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusSrcColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlDstColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusDstColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlSrcAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusSrcAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlDstAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusDstAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlConstantColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusConstantColor;
FOUNDATION_EXPORT NSString * const HGBlendModeGlConstantAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlOneMinusConstantAlpha;
FOUNDATION_EXPORT NSString * const HGBlendModeGlSrcAlphaSaturate;

#pragma mark - Value Options

FOUNDATION_EXPORT NSString *HGStringFromBlendingMode (GLuint blendingMode);
FOUNDATION_EXPORT GLuint HGBlendingModeFromString (NSString *string);

typedef NS_ENUM(NSInteger, HGParticleSystemPropertyOption)
{
    HGParticleSystemPropertyOptionConstant,
    HGParticleSystemPropertyOptionCurve,
    HGParticleSystemPropertyOptionRandomConstants,
    //    HGParticleSystemPropertyOptionRandomCurve,
    HGParticleSystemPropertyOptionColor,
    HGParticleSystemPropertyOptionColorRandomRGB,
    HGParticleSystemPropertyOptionColorRandomHSV,
    HGParticleSystemPropertyOptionGradient,
    HGParticleSystemPropertyOptionRandomColors,
    //    HGParticleSystemPropertyOptionRandomGradients,
    
    HGParticleSystemPropertyOptionUndefined = NSNotFound
};

// returns strings
FOUNDATION_EXPORT NSArray *HGParticleSystemPropertyOptionsForPropertyKey(NSString *propertyKey);

#pragma mark - Emitter shapes

typedef NS_ENUM(NSInteger, HGParticleSystemEmitterShape)
{
    HGParticleSystemEmitterShapeCircle = 0,
    HGParticleSystemEmitterShapeSector = 1,
    HGParticleSystemEmitterShapeRect = 2,
    HGParticleSystemEmitterShapeOval = 3,
    
    HGParticleSystemEmitterShapeUndefined = NSNotFound
};

FOUNDATION_EXPORT HGParticleSystemEmitterShape HGParticleSystemEmitterShapeFromString (NSString *string);

#pragma mark - Speed modes

typedef NS_ENUM(NSInteger, HGParticleSystemSpeedMode) {
    HGParticleSystemSpeedModeCurve = 0,
    HGParticleSystemSpeedModeAcceleration = 1,
    
    HGParticleSystemSpeedModeUndefined = NSNotFound,
};

FOUNDATION_EXPORT HGParticleSystemSpeedMode HGParticleSystemSpeedModeFromString (NSString *string);

#pragma mark - Rotation modes

typedef NS_ENUM(NSInteger, HGParticleSystemRotationMode) {
    HGParticleSystemRotationModeSpeed = 0,
    HGParticleSystemRotationModeFollow = 1,
    
    HGParticleSystemRotationModeUndefined = NSNotFound,
};

FOUNDATION_EXPORT HGParticleSystemRotationMode HGParticleSystemRotationModeFromString (NSString *string);

#pragma mark - Texture modes

typedef NS_ENUM(NSInteger, HGParticleSystemTextureMode)
{
    HGParticleSystemTextureModeEmbedded = 0,
    HGParticleSystemTextureModeFile = 1,
    HGParticleSystemTextureModeSpriteFrame = 2,
    
    HGParticleSystemTextureModeUndefined = NSNotFound,
};

FOUNDATION_EXPORT HGParticleSystemTextureMode HGParticleSystemTextureModeFromString (NSString *string);