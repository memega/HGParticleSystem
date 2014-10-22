//
//  HGParticleSystemKeys.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleSystemKeys.h"

#pragma mark - Property Keys

NSString * const HGDurationPropertyKey = @"duration";
NSString * const HGLoopingPropertyKey = @"looping";
NSString * const HGLifetimePropertyKey = @"lifetime";
NSString * const HGStartSizePropertyKey = @"startSize";
NSString * const HGStartSpeedPropertyKey = @"startSpeed";
NSString * const HGGravityPropertyKey = @"gravity";
NSString * const HGStartRotationPropertyKey = @"startRotation";
NSString * const HGStartColorPropertyKey = @"startColor";
NSString * const HGStartOpacityPropertyKey = @"startOpacity";
NSString * const HGMaxParticlesPropertyKey = @"maxParticles";
NSString * const HGEmissionModulePropertyKey = @"emissionModule";
NSString * const HGEmissionRatePropertyKey = @"emissionRate";

NSString * const HGEmitterShapeModulePropertyKey = @"shapeModule";
NSString * const HGEmitterShapePropertyKey = @"emitterShape";
NSString * const HGEmitterShapeRadiusPropertyKey = @"emitterShapeRadius";
NSString * const HGEmitterShapeAnglePropertyKey = @"emitterShapeAngle";
NSString * const HGEmitterShapeDirectionPropertyKey = @"emitterShapeDirection";
NSString * const HGEmitterShapeBoundaryPropertyKey = @"emitterShapeBoundary";
NSString * const HGEmitterShapeWidthPropertyKey = @"emitterShapeWidth";
NSString * const HGEmitterShapeHeightPropertyKey = @"emitterShapeHeight";
NSString * const HGEmitterShapeRandomDirectionPropertyKey = @"emitterShapeRandomDirection";

NSString * const HGEmitterShapeVerticalRatioPropertyKey = @"emitterShapeVerticalRatio";

NSString * const HGSpeedOverLifetimeModulePropertyKey = @"speedOverLifetimeModule";
NSString * const HGSpeedOverLifetimeModePropertyKey = @"speedOverLifetimeMode";
NSString * const HGSpeedOverLifetimePropertyKey = @"speedOverLifetime";
NSString * const HGSpeedOverLifetimeRadialAccelerationPropertyKey = @"speedOverLifetimeRadialAcceleration";
NSString * const HGSpeedOverLifetimeTangentialAccelerationPropertyKey = @"speedOverLifetimeTangentialAcceleration";

NSString * const HGSizeOverLifetimeModulePropertyKey = @"sizeOverLifetimeModule";
NSString * const HGSizeOverLifetimePropertyKey = @"sizeOverLifetime";

NSString * const HGRotationOverLifetimeModulePropertyKey = @"rotationOverLifetimeModule";
NSString * const HGRotationOverLifetimeModePropertyKey = @"rotationOverLifetimeMode";
NSString * const HGRotationAngularVelocityPropertyKey = @"rotationAngularVelocity";
NSString * const HGRotationRandomDirectionPropertyKey = @"rotationRandomDirection";

NSString * const HGSpinningOverLifetimeModulePropertyKey = @"spinningOverLifetimeModule";
NSString * const HGSpinningOverLifetimeAngularVelocityPropertyKey = @"spinningOverLifetimeAngularVelocity";

NSString * const HGColorOverLifetimeModulePropertyKey = @"colorOverLifetimeModule";
NSString * const HGColorOverLifetimePropertyKey = @"colorOverLifetime";

NSString * const HGOpacityOverLifetimeModulePropertyKey = @"opacityOverLifetimeModule";
NSString * const HGOpacityOverLifetimePropertyKey = @"opacityOverLifetime";

NSString * const HGBlendModulePropertyKey = @"blendModule";
NSString * const HGBlendingSrcPropertyKey = @"blendingSrc";
NSString * const HGBlendingDstPropertyKey = @"blendingDst";

NSString * const HGTexturePropertyKey = @"texture";
NSString * const HGTextureModulePropertyKey = @"textureModule";
NSString * const HGTextureModePropertyKey = @"textureMode";
NSString * const HGTextureFilePropertyKey = @"textureFile";
NSString * const HGTextureSpriteFrameSourcePropertyKey = @"textureSpriteFrameSource";
NSString * const HGTextureSpriteFramePropertyKey = @"textureSpriteFrame";

#pragma mark - Options

NSString * const HGPropertyValueOptionConstant = @"HGPropertyValueOptionConstant";
NSString * const HGPropertyValueOptionCurve = @"HGPropertyValueOptionCurve";
NSString * const HGPropertyValueOptionRandomConstants = @"HGPropertyValueOptionRandomConstants";
NSString * const HGPropertyValueOptionRandomCurve = @"HGPropertyValueOptionRandomCurve";

NSString * const HGPropertyValueOptionColor = @"HGPropertyValueOptionColor";
NSString * const HGPropertyValueOptionColorRandomRGB = @"HGPropertyValueOptionColorRandomRGB";
NSString * const HGPropertyValueOptionColorRandomHSV = @"HGPropertyValueOptionColorRandomHSV";
NSString * const HGPropertyValueOptionGradient = @"HGPropertyValueOptionGradient";
NSString * const HGPropertyValueOptionRandomColors = @"HGPropertyValueOptionRandomColors";
NSString * const HGPropertyValueOptionRandomGradients = @"HGPropertyValueOptionRandomGradients";

#pragma mark - Shape options

NSString * const HGParticleSystemEmitterShapeCircleValue = @"HGParticleSystemEmitterShapeCircleValue";
NSString * const HGParticleSystemEmitterShapeOvalValue = @"HGParticleSystemEmitterShapeOvalValue";
NSString * const HGParticleSystemEmitterShapeSectorValue = @"HGParticleSystemEmitterShapeSectorValue";
NSString * const HGParticleSystemEmitterShapeRectValue = @"HGParticleSystemEmitterShapeRectValue";

#pragma mark - Speed acceleration options

NSString * const HGParticleSystemSpeedCurve = @"HGParticleSystemSpeedCurve";
NSString * const HGParticleSystemSpeedAcceleration = @"HGParticleSystemSpeedAcceleration";

#pragma mark - Rotation options

NSString * const HGParticleSystemRotationVelocity = @"HGParticleSystemRotationVelocity";
NSString * const HGParticleSystemRotationFollow = @"HGParticleSystemRotationFollow";

#pragma mark - Texture Mode options

NSString * const HGTextureModeEmbedded = @"HGTextureModeEmbedded";
NSString * const HGTextureModeFile = @"HGTextureModeFile";
NSString * const HGTextureModeSpriteFrame = @"HGTextureModeSpriteFrame";

#pragma mark - GL Blending Modes

NSString * const HGBlendModeGlZero = @"GL_ZERO";
NSString * const HGBlendModeGlOne = @"GL_ONE";
NSString * const HGBlendModeGlSrcColor = @"GL_SRC_COLOR";
NSString * const HGBlendModeGlOneMinusSrcColor = @"GL_ONE_MINUS_SRC_COLOR";
NSString * const HGBlendModeGlDstColor = @"GL_DST_COLOR";
NSString * const HGBlendModeGlOneMinusDstColor = @"GL_ONE_MINUS_DST_COLOR";
NSString * const HGBlendModeGlSrcAlpha = @"GL_SRC_ALPHA";
NSString * const HGBlendModeGlOneMinusSrcAlpha = @"GL_ONE_MINUS_SRC_ALPHA";
NSString * const HGBlendModeGlDstAlpha = @"GL_DST_ALPHA";
NSString * const HGBlendModeGlOneMinusDstAlpha = @"GL_ONE_MINUS_DST_ALPHA";
NSString * const HGBlendModeGlConstantColor = @"GL_CONSTANT_COLOR";
NSString * const HGBlendModeGlOneMinusConstantColor = @"GL_ONE_MINUS_CONSTANT_COLOR";
NSString * const HGBlendModeGlConstantAlpha = @"GL_CONSTANT_ALPHA";
NSString * const HGBlendModeGlOneMinusConstantAlpha = @"GL_ONE_MINUS_CONSTANT_ALPHA";
NSString * const HGBlendModeGlSrcAlphaSaturate = @"GL_SRC_ALPHA_SATURATE";


#pragma mark - Value Options

HGParticleSystemEmitterShape HGParticleSystemEmitterShapeFromString (NSString *string)
{
    static NSDictionary *propertiesDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertiesDictionary = @{
                                 HGParticleSystemEmitterShapeCircleValue: @(HGParticleSystemEmitterShapeCircle),
                                 HGParticleSystemEmitterShapeSectorValue: @(HGParticleSystemEmitterShapeSector),
                                 HGParticleSystemEmitterShapeRectValue: @(HGParticleSystemEmitterShapeRect),
                                 };
    });
    return [propertiesDictionary[string] integerValue];
}

HGParticleSystemSpeedMode HGParticleSystemSpeedModeFromString (NSString *string)
{
    static NSDictionary *propertiesDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertiesDictionary = @{
                                 HGParticleSystemSpeedCurve: @(HGParticleSystemSpeedModeCurve),
                                 HGParticleSystemSpeedAcceleration: @(HGParticleSystemSpeedModeAcceleration),
                                 };
    });
    return [propertiesDictionary[string] integerValue];
}

HGParticleSystemRotationMode HGParticleSystemRotationModeFromString (NSString *string)
{
    static NSDictionary *propertiesDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertiesDictionary = @{
                                 HGParticleSystemRotationVelocity: @(HGParticleSystemRotationModeSpeed),
                                 HGParticleSystemRotationFollow: @(HGParticleSystemRotationModeFollow),
                                 };
    });
    return [propertiesDictionary[string] integerValue];
}

HGParticleSystemTextureMode HGParticleSystemTextureModeFromString (NSString *string)
{
    static NSDictionary *textureModes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        textureModes = @{
                         HGTextureModeEmbedded: @(HGParticleSystemTextureModeEmbedded),
                         HGTextureModeFile: @(HGParticleSystemTextureModeFile),
                         HGTextureModeSpriteFrame: @(HGParticleSystemTextureModeSpriteFrame),
                         };
    });
    return [textureModes[string] integerValue];
}

static NSDictionary *blendModeByKey = nil;
void HGInitializeBlendingModesDictionary()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blendModeByKey = @{
                           HGBlendModeGlZero: @(GL_ZERO),
                           HGBlendModeGlOne: @(GL_ONE),
                           HGBlendModeGlSrcColor: @(GL_SRC_COLOR),
                           HGBlendModeGlOneMinusSrcColor: @(GL_ONE_MINUS_SRC_COLOR),
                           HGBlendModeGlDstColor: @(GL_DST_COLOR),
                           HGBlendModeGlOneMinusDstColor: @(GL_ONE_MINUS_DST_COLOR),
                           HGBlendModeGlSrcAlpha: @(GL_SRC_ALPHA),
                           HGBlendModeGlOneMinusSrcAlpha: @(GL_ONE_MINUS_SRC_ALPHA),
                           HGBlendModeGlDstAlpha: @(GL_DST_ALPHA),
                           HGBlendModeGlOneMinusDstAlpha: @(GL_ONE_MINUS_DST_ALPHA),
                           HGBlendModeGlConstantColor: @(GL_CONSTANT_COLOR),
                           HGBlendModeGlOneMinusConstantColor: @(GL_ONE_MINUS_CONSTANT_COLOR),
                           HGBlendModeGlConstantAlpha: @(GL_CONSTANT_ALPHA),
                           HGBlendModeGlOneMinusConstantAlpha: @(GL_ONE_MINUS_CONSTANT_ALPHA),
                           HGBlendModeGlSrcAlphaSaturate: @(GL_SRC_ALPHA_SATURATE),
                           };
    });
}

GLuint HGBlendingModeFromString (NSString *string)
{
    HGInitializeBlendingModesDictionary();
    
    return [blendModeByKey[string] unsignedIntValue];
}

NSString *HGStringFromBlendingMode (GLuint blendingMode)
{
    HGInitializeBlendingModesDictionary();
    
    NSArray *allKeys = [blendModeByKey allKeysForObject:@(blendingMode)];
    if (allKeys.count > 0)
        return allKeys.firstObject;

    return nil;
}

