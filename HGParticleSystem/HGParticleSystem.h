//
//  HGParticleSystem.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 08/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#if defined(__has_include)
    #if __has_include("cocos2d.h")
        #import "cocos2d.h"
    #else
        #define _HGParticleSystemNoCocos
        #error Please add a Header Search Path to cocos2d in project Build Settings.
    #endif
#else
    #import "cocos2d.h"
#endif

#import "HGParticleSystemProperty.h"

#pragma mark - Property keys

/**
 *  Maximum capacity of the particle system. Read-only property, attempting to set its value raises an exception. NSUInteger value.
 */
FOUNDATION_EXPORT NSString * const HGMaxParticlesPropertyKey;
/**
 *  Duration of the particle system. NSTimeInterval value.
 */
FOUNDATION_EXPORT NSString * const HGDurationPropertyKey;
/**
 *  Setting this property to YES makes the particle system repeat after its lasted its duration. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGLoopingPropertyKey;
/**
 *  A single particle lifetime. HGPropertyRef float value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGLifetimePropertyKey;
/**
 *  Initial size of a particle. HGPropertyRef float value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGStartSizePropertyKey;
/**
 *  Initial movement speed of a particle. HGPropertyRef float value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGStartSpeedPropertyKey;
/**
 *  Initial rotation of a particle, in radians. HGPropertyRef float value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGStartRotationPropertyKey;
/**
 *  Initial color of a particle. HGPropertyRef UIColor/NSColor value. Accepts HGPropertyValueOptionColor, HGPropertyValueOptionColorRandomRGB, HGPropertyValueOptionColorRandomHSV, HGPropertyValueOptionGradient and HGPropertyValueOptionRandomColors options.
 */
FOUNDATION_EXPORT NSString * const HGStartColorPropertyKey;
/**
 *  Initial opacity of a particle, in range from 0.0 to 1.0. HGPropertyRef value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGStartOpacityPropertyKey;
/**
 *  Particle system gravity. GLKVector2 value.
 */
FOUNDATION_EXPORT NSString * const HGGravityPropertyKey;

#pragma mark - Modules

/**
 *  Emission module. Setting to NO would cause the particle emission rate drop to 0.0, effectively stopping any particle emission. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGEmissionModulePropertyKey;
/**
 *  Particle emission rate, in particles per second. HGPropertyRef float value. Accepts HGPropertyValueOptionConstant and HGPropertyValueOptionCurve.
 */
FOUNDATION_EXPORT NSString * const HGEmissionRatePropertyKey;

/**
 *  Emitter shape module. If set to NO, particles emit from a single point moving in same direction. If set to YES, emitter shape is defined by properties described below. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeModulePropertyKey;
/**
 *  Emitter shape. HGParticleSystemEmitterShape value. See HGParticleSystemEmitterShape for available options.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapePropertyKey;
/**
 *  Radius of a circle, an oval or a sector emitter. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeRadiusPropertyKey;
/**
 *  Central angle of a sector emitter, in degrees. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeAnglePropertyKey;
/**
 *  Direction of a sector emitter, in degrees. Direction of particle movement of a rectangle emitter, in degrees. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeDirectionPropertyKey;
/**
 *  Width of a rectangle emitter. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeWidthPropertyKey;
/**
 *  Height of a rectangle emitter. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeHeightPropertyKey;
/**
 *  If set to YES, particles of a rectangle emitter would move in a random direction. Default NO. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeRandomDirectionPropertyKey;
/**
 *  Vertical squish ratio of an ellipse emitter. Height of the ellipse equals verticalRatio * 2 * radius. CGFloat value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeVerticalRatioPropertyKey;
/**
 *  If set to YES, particles are being emitted from the shape edge only. Default NO. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGEmitterShapeBoundaryPropertyKey;

/**
 *  Speed over particle lifetime module. If set to YES, particle speed change over it's lifetime may be controlled.
 */
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModulePropertyKey;
/**
 *  Speed change mode. HGParticleSystemSpeedMode value. See HGParticleSystemSpeedMode for more details.
 */
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeModePropertyKey;
/**
 *  Curve for the HGParticleSystemSpeedModeCurve mode. HGPropertyRef value. Accepts HGPropertyValueOptionCurve option.
 */
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimePropertyKey;
/**
 *  Radial acceleration for the HGParticleSystemSpeedModeAcceleration mode. HGPropertyRef value. Accepts HGPropertyValueOptionConstant and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeRadialAccelerationPropertyKey;
/**
 *  Tangential acceleration for the HGParticleSystemSpeedModeAcceleration mode. HGPropertyRef value. Accepts HGPropertyValueOptionConstant and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGSpeedOverLifetimeTangentialAccelerationPropertyKey;

/**
 *  Size over particle lifetime module. If set to YES, particle size change over it's lifetime may be controlled.
 */
FOUNDATION_EXPORT NSString * const HGSizeOverLifetimeModulePropertyKey;
/**
 *  HGPropertyRef value. Accepts HGPropertyValueOptionRandomCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGSizeOverLifetimePropertyKey;

/**
 *  Rotation over particle lifetime module.
 */
FOUNDATION_EXPORT NSString * const HGRotationOverLifetimeModulePropertyKey;
/**
 *  Rotation change mode. HGParticleSystemRotationMode value. See HGParticleSystemRotationMode for more details.
 */
FOUNDATION_EXPORT NSString * const HGRotationOverLifetimeModePropertyKey;
/**
 *  Angular velocity, in degrees. HGPropertyRef value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGRotationAngularVelocityPropertyKey;
/**
 *  If set to YES, angular velocity sign would be random for each particle. Default NO. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGRotationRandomDirectionPropertyKey;

/**
 *  Spinning over particle lifetime module. If set to YES, particles would rotate in 3D space around a random axis. BOOL value.
 */
FOUNDATION_EXPORT NSString * const HGSpinningOverLifetimeModulePropertyKey;
/**
 *  Angular velocity of particle spinning. HGPropertyRef value. Accepts HGPropertyValueOptionConstant, HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGSpinningOverLifetimeAngularVelocityPropertyKey;

/**
 *  Color over particle lifetime module. If set to YES, particle color change may be controlled.
 */
FOUNDATION_EXPORT NSString * const HGColorOverLifetimeModulePropertyKey;
/**
 *  Specifies how the particle color changes. HGPropertyRef value. Accepts HGPropertyValueOptionGradient, HGPropertyValueOptionColorRandomHSV, and HGPropertyValueOptionColorRandomRGB options.
 */
FOUNDATION_EXPORT NSString * const HGColorOverLifetimePropertyKey;

/**
 *  Opacity over particle lifetime module. If set to YES, particle opacity change may be controlled.
 */
FOUNDATION_EXPORT NSString * const HGOpacityOverLifetimeModulePropertyKey;
/**
 *  Specifies how the particle opacity changes. HGPropertyRef value. Accepts HGPropertyValueOptionCurve and HGPropertyValueOptionRandomConstants options.
 */
FOUNDATION_EXPORT NSString * const HGOpacityOverLifetimePropertyKey;

/**
 *  OpenGL blending module. If set to YES, particle system blending function may be controlled.
 */
FOUNDATION_EXPORT NSString * const HGBlendModulePropertyKey;
/**
 *  OpenGL source blending function. Accepts valid blending function options.
 */
FOUNDATION_EXPORT NSString * const HGBlendingSrcPropertyKey;
/**
 *  OpenGL destination blending function. Accepts valid blending function options.
 */
FOUNDATION_EXPORT NSString * const HGBlendingDstPropertyKey;

/**
 *  This function returns an array of valid HGPropertyRef options for the given property key, or nil if the property does not accept an HGPropertyRef value. See HGParticleSystemProperty.h for descriptions of available options.
 *
 *  @param propertyKey Property key, see list above.
 *
 *  @return An array of NSStrings describing valid HGPropertyRef options, or nil.
 */
FOUNDATION_EXPORT NSArray *HGParticleSystemPropertyOptionsForPropertyKey(NSString *propertyKey);

#pragma mark - Emitter shapes

/**
 *  Defines the emitter shape when emitter shape module is on.
 */
typedef NS_ENUM(NSInteger, HGParticleSystemEmitterShape){
    /**
     *  Circle emitter.
     */
    HGParticleSystemEmitterShapeCircle = 0,
    /**
     *  Sector emitter.
     */
    HGParticleSystemEmitterShapeSector = 1,
    /**
     *  Rectangular emitter.
     */
    HGParticleSystemEmitterShapeRect = 2,
    /**
     *  Ellipse emitter.
     */
    HGParticleSystemEmitterShapeOval = 3,
    /**
     *  Undefined emitter shape.
     */
    HGParticleSystemEmitterShapeUndefined = NSNotFound
};

#pragma mark - Speed modes

/**
 *  Speed over lifetime modes.
 */
typedef NS_ENUM(NSInteger, HGParticleSystemSpeedMode) {
    /**
     *  Particle speed changes according to the specified curve.
     */
    HGParticleSystemSpeedModeCurve = 0,
    /**
     *  Particle speed changes according to the acceleration values.
     */
    HGParticleSystemSpeedModeAcceleration = 1,
    /**
     *  Undefined speed change mode.
     */
    HGParticleSystemSpeedModeUndefined = NSNotFound,
};

#pragma mark - Rotation modes

/**
 *  Rotation over lifetime modes.
 */
typedef NS_ENUM(NSInteger, HGParticleSystemRotationMode){
    /**
     *  Rotation changes with specified angular velocity.
     */
    HGParticleSystemRotationModeSpeed = 0,
    /**
     *  Rotation follows particle movement direction.
     */
    HGParticleSystemRotationModeFollow = 1,
    /**
     *  Undefined rotation change mode.
     */
    HGParticleSystemRotationModeUndefined = NSNotFound,
};

#pragma mark - Notifications

/**
 *  Sent when a non-looped particle system completes.
 */
FOUNDATION_EXPORT NSString * const HGParticleSystemDidFinishNotification;

/**
 *  Sent when parent property of a particle system becomes nil.
 *  Note that if used with cache, it would mark this system as available and it should not be reused again.
 */
FOUNDATION_EXPORT NSString * const HGParticleSystemDidBecomeAvailableNotification;

#pragma mark - HGParticleSystem

/**
 A particle system node.
 All properties of a particle system can be read with valueForKey: and set with setValue:forKey: selectors. See descriptions of specific keys for expected value types and available options.
 */
@interface HGParticleSystem : CCNode

/**
 *  Designated initializer. Creates an empty particle system with given capacity.
 *
 *  @param maxParticles Maximum number of particles.
 *
 *  @return New instance of the particle system node.
 */
- (instancetype)initWithMaxParticles:(NSUInteger)maxParticles;

/**
 *  Convenience initializer. Loads a particle system description created in the HGParticleSystemEditor, if file exists.
 *
 *  @param filename File name
 *
 *  @return New instance of the particle system node.
 */
- (instancetype)initWithFile:(NSString *)filename;

/**
 *  Convenience initializer. Creates a new instance with a dictionary created in the Particle System Editor.
 *
 *  @param dictionary A dictionary containing a particle system description created in the HGParticleSystemEditor.
 *
 *  @return New instance of the particle system node
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Returns YES if particle system is active.
 */
@property (nonatomic, readonly) BOOL active;

/** 
 * Number of particles being simulated at the moment. 
 */
@property (nonatomic, readonly) NSUInteger particleCount;

/** 
 * If set to YES, the particle system will be removed from parent after completion. Default NO.
 */
@property (nonatomic) BOOL autoRemoveOnFinish;

/** 
 * If set to YES, the particle system will reset when its visibility property is set to YES. Default NO.
 */
@property (nonatomic) BOOL resetOnVisibilityToggle;

/**
 *  Set the particle system texture using specified texture and texture coords value.
 *
 *  @param texture Texture
 *  @param rect    Texture coords
 */
- (void)setTexture:(CCTexture *)texture withRect:(CGRect)rect;

/**
 *  Stops the particle system updates.
 */
- (void)stopSystem;
/**
 *  Resets the particle system and starts updating.
 */
- (void)resetSystem;

/**
 *  Initial delay before the system starts emitting particles.
 */
@property (nonatomic) CCTime startDelay;

/**
 *  Animation speed multiplier. Increasing this value above 1.0 will speed up the particle system. Calling resetSystem resets this value to 1.0.
 *  Default 1.0.
 */
@property (nonatomic) CGFloat actionSpeed;

/**
 *  Changes a property at runtime. See particle system keys for more information. Changing certain properties after any particles have been generated may have adverse effects.
 *
 *  @param property    Property value object, see HGParticleSystemProperty.h for more information.
 *  @param propertyKey Property key.
 *  
 *  @see HGParticleSystemProperty.h
 */
- (void)setProperty:(HGPropertyRef)property forKey:(NSString *)propertyKey;

#pragma mark - Convenience setters

/**
 *  Assigns a constant value to a dynamic property at runtime. Note that the property with specified key must accept constant values; see key descriptions for more details.
 *
 *  @param constant    Constant value to assign.
 *  @param propertyKey Property key.
 */
- (void)setPropertyWithConstant:(const CGFloat)constant forKey:(NSString *)propertyKey;

/**
 *  Specifies that a dynamic property should have a random float value distributed evenly between two constants. Note that the property with specified key must accept random constant values; see key descriptions for more details.
 *
 *  @param constant1    The first constant value of the random values range.
 *  @param constant2    The second constant value of the random values range.
 *  @param propertyKey  Property key.
 */
- (void)setPropertyWithConstant1:(const CGFloat)constant1 constant2:(const CGFloat)constant2 forKey:(NSString *)propertyKey;

/**
 *  Assigns a constant color value to a dynamic property at runtime. Note that the property with specified key must accept color values; see key descriptions for more details.
 *
 *  @param color       UIColor or NSColor object, depending on the platform.
 *  @param propertyKey Property key.
 */
- (void)setPropertyWithColor:(HGColor * const)color forKey:(NSString *)propertyKey;

@end
