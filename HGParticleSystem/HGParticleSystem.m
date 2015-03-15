//
//  HGParticleSystem.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 08/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleSystem.h"

#import <objc/runtime.h>

#if __has_include("CCNode_Private.h")
#import "CCNode_Private.h"
#endif

#if __has_include("CCTextureCache.h")
#import "CCTextureCache.h"
#endif

#if __has_include("CCShader.h")
#import "CCShader.h"
#endif

// data values
#import "HGParticleSystemKeys.h"
#import "HGParticleSystemProperty.h"

// helpers
#import "HGAssert.h"
#import "HGTypes.h"

#pragma mark - Constants

NSString * const HGParticleSystemDidFinishNotification = @"HGParticleSystemDidFinishNotification";
NSString * const HGParticleSystemDidBecomeAvailableNotification = @"HGParticleSystemDidBecomeAvailableNotification";

__unused
FOUNDATION_STATIC_INLINE
CGPoint HGPointOnRect(const CGPoint normalizedVectorFromCenter, const CGRect rect)
{
    if (CGRectGetWidth(rect) == 0. || CGRectGetHeight(rect) == 0.)
        return CGPointZero;
    
    CGFloat t = INFINITY, tmp;
    if (normalizedVectorFromCenter.x)
    {
        // left edge
        tmp = CGRectGetMinX(rect) / normalizedVectorFromCenter.x;
        if (tmp > 0.f) t = MIN(t, tmp);
        
        // right edge
        tmp = CGRectGetMaxX(rect) / normalizedVectorFromCenter.x;
        if (tmp > 0.f) t = MIN(t, tmp);
    }
    if (normalizedVectorFromCenter.y)
    {
        // top edge
        tmp = CGRectGetMaxY(rect) / normalizedVectorFromCenter.y;
        if (tmp > 0.f) t = MIN(t, tmp);
        
        // bottom edge
        tmp = CGRectGetMinY(rect) / normalizedVectorFromCenter.y;
        if (tmp > 0.f) t = MIN(t, tmp);
    }
    
    if (t == INFINITY) return CGPointZero; // should never happen actually

    return ccpMult(normalizedVectorFromCenter, t);
}

#if HG_DEBUG_PROFILING && defined(__has_include) && __has_include("CCProfiling.h")
#import "CCProfiling.h"
#define HG_PROFILING_BEGIN(string) CCProfilingBeginTimingBlock((string))
#define HG_PROFILING_END(string) CCProfilingEndTimingBlock((string))
#else
#define HG_PROFILING_BEGIN(string)
#define HG_PROFILING_END(string)
#endif

#pragma mark - Particle

typedef struct
{
    HGFloat elapsed;
    HGFloat lifetime;
    
    GLKVector2 position;
    GLKVector2 startPosition;
    
    GLKVector3 color;
    GLKVector3 startColor;
    GLKVector3 colorVelocity;
    
    HGFloat opacity;
    HGFloat startOpacity;
    HGFloat opacityVelocity;
    
    HGFloat size;
    HGFloat startSize;
    HGFloat sizeVelocity;
    
    HGFloat rotation;
    HGFloat startRotation;
    HGFloat angularVelocity;
    
    GLKVector2 speed;
    GLKVector2 startSpeed;
    
    HGFloat radialAcceleration;
    HGFloat tangentialAcceleration;
    
    GLKVector3 spinningAxis;
    HGFloat spinningAngle;
    HGFloat spinningVelocity;
    
} HGParticle;

#pragma mark - Particle System

@interface HGParticleSystem ()
{
    HGParticle *_particles;
    NSUInteger _totalParticles;
    NSUInteger _allocatedParticles;
    
    NSUInteger _maxParticles;
    NSTimeInterval _duration;
    
    BOOL _looping;
    HGPropertyRef _lifetime;  // constant, curve, random
    HGPropertyRef _startSize;  // constant, curve, random
    HGPropertyRef _startSpeed;  // constant, curve, random
    HGPropertyRef _startRotation; // constant, curve, random
    HGPropertyRef _startColor;  // constant, gradient
    HGPropertyRef _startOpacity; // constant, curve, random
    
    GLKVector2 _gravity;
    
    BOOL _emissionModule;
    HGPropertyRef _emissionRate; // constant, curve
    
    BOOL _shapeModule;
    HGParticleSystemEmitterShape _emitterShape;
    HGFloat _emitterShapeRadius;
    HGFloat _emitterShapeAngle;
    HGFloat _emitterShapeDirection;
    HGFloat _emitterShapeWidth;
    HGFloat _emitterShapeHeight;
    CGRect _emitterRect; // small optimization, pre-calculated
    BOOL _emitterShapeBoundary;
    BOOL _emitterShapeRandomDirection;
    
    HGFloat _emitterShapeVerticalRatio;
    
    BOOL _sizeOverLifetimeModule;
    HGPropertyRef _sizeOverLifetime; // curve, random
    
    BOOL _speedOverLifetimeModule;
    HGParticleSystemSpeedMode _speedOverLifetimeMode;
    HGPropertyRef _speedOverLifetime; // curve, random
    HGPropertyRef _speedOverLifetimeRadialAcceleration; // constant, curve, random
    HGPropertyRef _speedOverLifetimeTangentialAcceleration; // constant, curve, random
    
    BOOL _colorOverLifetimeModule;
    HGPropertyRef _colorOverLifetime; // gradient, random color
    
    BOOL _opacityOverLifetimeModule;
    HGPropertyRef _opacityOverLifetime; // curve, random
    
    BOOL _rotationOverLifetimeModule;
    HGParticleSystemRotationMode _rotationOverLifetimeMode;
    HGPropertyRef _rotationAngularVelocity; // constant, gradient
    BOOL _rotationRandomDirection;
    
    BOOL _spinningOverLifetimeModule;
    HGPropertyRef _spinningOverLifetimeAngularVelocity;
    
    BOOL _blendModule;
    GLuint _blendingSrc;
    GLuint _blendingDst;
    
    //
    // CCParticleSystem Copy-Paste
    //
    
	// Time elapsed since the start of the system (in seconds).
	NSTimeInterval _elapsed;
    
    // Particle emission counter.
	NSTimeInterval _emitCounter;
    
	// Whether or not the node will be auto-removed when there are not particles.
	BOOL	_autoRemoveOnFinish;
    
    // The particly system resetd upon visibility toggling to True.
    BOOL    _resetOnVisibilityToggle;
    
	// YES if scaled or rotated.
	BOOL _transformSystemDirty;
    
    GLKVector2 _texCoord1[4];
    
    // Movment type: free or grouped.
	CCParticleSystemPositionType	_particlePositionType;
}

//@property (nonatomic) NSTimeInterval duration;
//@property (nonatomic) NSUInteger maxParticles;
//@property (nonatomic) BOOL looping;
//@property (nonatomic) HGPropertyRef lifetime; // constant, curve, random
//@property (nonatomic) HGPropertyRef startSize; // constant, curve, random
//@property (nonatomic) HGPropertyRef startSpeed; // constant, curve, random
//@property (nonatomic) HGPropertyRef startRotation; // constant, curve, random
//@property (nonatomic) HGPropertyRef startColor; // constant color, gradient
//
//@property (nonatomic) GLKVector2 gravity;
//
//@property (nonatomic) BOOL emissionModule;
//@property (nonatomic) HGFloat emissionRate;

@end

@implementation HGParticleSystem

+ (NSSet *)propertyRefKeys
{
    return [NSSet setWithArray:@[
                                 HGLifetimePropertyKey,
                                 HGStartSizePropertyKey,
                                 HGStartSpeedPropertyKey,
                                 HGStartRotationPropertyKey,
                                 HGStartColorPropertyKey,
                                 HGStartOpacityPropertyKey,
                                 HGEmissionRatePropertyKey,
                                 HGRotationAngularVelocityPropertyKey,
                                 HGSpinningOverLifetimeAngularVelocityPropertyKey,
                                 HGSizeOverLifetimePropertyKey,
                                 HGSpeedOverLifetimePropertyKey,
                                 HGSpeedOverLifetimeRadialAccelerationPropertyKey,
                                 HGSpeedOverLifetimeTangentialAccelerationPropertyKey,
                                 HGColorOverLifetimePropertyKey,
                                 HGOpacityOverLifetimePropertyKey,
                                 ]];
}

+ (NSSet *)propertyKeys
{
    return [NSSet setWithArray:@[
                                 HGMaxParticlesPropertyKey,
                                 HGDurationPropertyKey,
                                 HGLoopingPropertyKey,
                                 HGLifetimePropertyKey,
                                 HGStartSizePropertyKey,
                                 HGStartSpeedPropertyKey,
                                 HGStartRotationPropertyKey,
                                 HGStartColorPropertyKey,
                                 HGStartOpacityPropertyKey,
                                 HGGravityPropertyKey,
                                 
                                 HGEmissionModulePropertyKey,
                                 HGEmissionRatePropertyKey,
                                 
                                 HGRotationOverLifetimeModulePropertyKey,
                                 HGRotationOverLifetimeModePropertyKey,
                                 HGRotationAngularVelocityPropertyKey,
                                 HGRotationRandomDirectionPropertyKey,
                                 
                                 HGSpeedOverLifetimeModulePropertyKey,
                                 HGSpeedOverLifetimeModePropertyKey,
                                 HGSpeedOverLifetimePropertyKey,
                                 HGSpeedOverLifetimeRadialAccelerationPropertyKey,
                                 HGSpeedOverLifetimeTangentialAccelerationPropertyKey,
                                 
                                 HGSizeOverLifetimeModulePropertyKey,
                                 HGSizeOverLifetimePropertyKey,
                                 
                                 HGEmitterShapeModulePropertyKey,
                                 HGEmitterShapePropertyKey,
                                 HGEmitterShapeRadiusPropertyKey,
                                 HGEmitterShapeAnglePropertyKey,
                                 HGEmitterShapeDirectionPropertyKey,
                                 HGEmitterShapeBoundaryPropertyKey,
                                 HGEmitterShapeWidthPropertyKey,
                                 HGEmitterShapeHeightPropertyKey,
                                 HGEmitterShapeRandomDirectionPropertyKey,
                                 HGEmitterShapeVerticalRatioPropertyKey,
                                 
                                 HGColorOverLifetimeModulePropertyKey,
                                 HGColorOverLifetimePropertyKey,
                                 
                                 HGOpacityOverLifetimeModulePropertyKey,
                                 HGOpacityOverLifetimePropertyKey,
                                 
                                 HGBlendModulePropertyKey, HGBlendingSrcPropertyKey, HGBlendingDstPropertyKey,
                                 
                                 HGSpinningOverLifetimeModulePropertyKey,
                                 HGSpinningOverLifetimeAngularVelocityPropertyKey,
                                 ]];
}

- (instancetype)init
{
    HGAssert(NO, @"HGParticleSystem: Use the designated initializer -initWithDictionary:");
    return nil;
}

-(instancetype) initWithFile:(NSString *)plistFile
{
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:plistFile];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
	HGAssert(dict, @"HGParticleSystem: file not found");
	
	return [self initWithDictionary:dict];
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    HGAssert(dictionary, @"HGParticleSystem: empty dictionary.");
    self = [super init];
    if (self)
    {
        self.actionSpeed = 1.;
        
        // nice!
        NSSet *set = [[self class] propertyKeys];
        [set enumerateObjectsUsingBlock:^(id propertyKey, BOOL *stop) {
            id value = [dictionary valueForKey:propertyKey];
            
            if (value == nil && [HGEmitterShapeVerticalRatioPropertyKey isEqualToString:propertyKey])
            {
                value = @(1.);
            }
            else
            {
                HGMissingValue(value, propertyKey);
            }
            
            // special cases
            if ([HGSpeedOverLifetimeModePropertyKey isEqualToString:propertyKey])
            {
                value = @(HGParticleSystemSpeedModeFromString(value));
            }
            else if ([HGEmitterShapePropertyKey isEqualToString:propertyKey])
            {
                value = @(HGParticleSystemEmitterShapeFromString(value));
            }
            else if ([HGBlendingSrcPropertyKey isEqualToString:propertyKey])
            {
                value = @(HGBlendingModeFromString(value));
            }
            else if ([HGBlendingDstPropertyKey isEqualToString:propertyKey])
            {
                value = @(HGBlendingModeFromString(value));
            }
            else if ([HGRotationOverLifetimeModePropertyKey isEqualToString:propertyKey])
            {
                value = @(HGParticleSystemRotationModeFromString(value));
            }
            
            [self setValue:value forKey:propertyKey];
        }];
        
        // tiny optimization
        if (_emitterShape == HGParticleSystemEmitterShapeRect)
        {
            _emitterRect = CGRectMake(- _emitterShapeWidth * .5f, - _emitterShapeHeight * .5f,
                                      _emitterShapeWidth, _emitterShapeHeight);
        }
        
        // allocate
        _totalParticles = _maxParticles;
        _particles = calloc(_totalParticles, sizeof(HGParticle));
        if (!_particles)
        {
            CCLOG(@"Particle system: not enough memory");
            return nil;
        }
        _allocatedParticles = _maxParticles;
        
        if (_blendModule)
        {
            self.blendMode = [CCBlendMode blendModeWithOptions:@{
                                                                 CCBlendFuncSrcColor: @(_blendingSrc),
                                                                 CCBlendFuncDstColor: @(_blendingDst),
                                                                 }];
        }
        else
        {
            self.blendMode = [CCBlendMode premultipliedAlphaMode]; // default blend function
        }
        
        //
        // FIXME: use Cocos2d cache or create own
        //
        BOOL textureModule = [[dictionary valueForKey:HGTextureModulePropertyKey] boolValue];
        if (textureModule)
        {
            HGParticleSystemTextureMode textureMode = HGParticleSystemTextureModeFromString([dictionary valueForKey:HGTextureModePropertyKey]);
            if (textureMode == HGParticleSystemTextureModeEmbedded)
            {
                id texture = [dictionary valueForKey:HGTexturePropertyKey];
                if (texture)
                {
                    NSString *base64String = texture[@"base64"];
                    if (base64String)
                    {
                        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String
                                                                           options:0];
                        if (data)
                        {
        #ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            CGImageRef CGImage = [image CGImage];
        #elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
                            NSImage *image = [[NSImage alloc] initWithData:data];
                            CGImageRef CGImage = [image CGImageForProposedRect:NULL
                                                                       context:NULL
                                                                         hints:nil];
        #endif
                            CCTexture *texture = [[CCTexture alloc] initWithCGImage:CGImage
                                                                       contentScale:CCDirector.sharedDirector.contentScaleFactor];
                            
                            [self setTexture:texture];
                        }
                    }
                }
            }
            else if (textureMode == HGParticleSystemTextureModeFile)
            {
                NSString *textureFile = [dictionary valueForKey:HGTextureFilePropertyKey];
                if (textureFile)
                {
#if __CC_PLATFORM_IOS
                    // should really be using the last component
                    textureFile = textureFile.lastPathComponent;
#endif
                    CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage:textureFile];

                    if (texture)
                    {
                        [self setTexture:texture];
                    }
                }
            }
            else if (textureMode == HGParticleSystemTextureModeSpriteFrame)
            {
                NSString *textureSpriteFrameSource = [dictionary valueForKey:HGTextureSpriteFrameSourcePropertyKey];
                NSString *textureSpriteFrame = [dictionary valueForKey:HGTextureSpriteFramePropertyKey];
                if (textureSpriteFrameSource.length > 0 && textureSpriteFrame.length > 0)
                {
#if __CC_PLATFORM_IOS
                    // should really be using the last component
                    textureSpriteFrameSource = textureSpriteFrameSource.lastPathComponent;
#endif
                    
                    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:textureSpriteFrameSource];
                    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
                    
                    NSString *texturePath = nil;
                    NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
                    if( metadataDict )
                        // try to read  texture file name from meta data
                        texturePath = [metadataDict objectForKey:@"textureFileName"];
                    
                    
                    if( texturePath )
                    {
                        // build texture path relative to plist file
                        NSString *textureBase = [textureSpriteFrameSource stringByDeletingLastPathComponent];
                        texturePath = [textureBase stringByAppendingPathComponent:texturePath];
                    } else {
                        // build texture path by replacing file extension
                        texturePath = [textureSpriteFrameSource stringByDeletingPathExtension];
                        texturePath = [texturePath stringByAppendingPathExtension:@"png"];
                        
                        NSLog(@"HGParticleSystem: Trying to use file '%@' as texture", texturePath);
                    }

                    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:path textureFilename:texturePath];
                    
                    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:textureSpriteFrame];
                    if (spriteFrame)
                    {
                        [self setSpriteFrame:spriteFrame];
                    }
                    else
                    {
                        NSLog(@"HGParticleSystem: Missing sprite frame %@", textureSpriteFrame);
                    }
                }
            }
        }
        //
        // CCParticleSystem Copy-Paste
        //
        
        // default, active
		_active = YES;
        
        // default, remove automatically
		_autoRemoveOnFinish = YES;
        
        _resetOnVisibilityToggle = YES;
        
		//for batchNode
		_transformSystemDirty = NO;
        
        // default movement type;
		_particlePositionType = CCParticleSystemPositionTypeGrouped;
        
        self.shader = [CCShader positionTextureColorShader];
    }
    return self;
}

- (void)dealloc
{
    if (_particles)
    {
        free(_particles);
    }
    
    //
    // FIXME: double-check the list of properties to be released
    //
    if (_lifetime) HGPropertyRelease(_lifetime);
    if (_startSize) HGPropertyRelease(_startSize);
    if (_startSpeed) HGPropertyRelease(_startSpeed);
    if (_startRotation) HGPropertyRelease(_startRotation);
    if (_startColor) HGPropertyRelease(_startColor);
    if (_startOpacity) HGPropertyRelease(_startOpacity);
    if (_emissionRate) HGPropertyRelease(_emissionRate);
    if (_rotationAngularVelocity) HGPropertyRelease(_rotationAngularVelocity);
    if (_spinningOverLifetimeAngularVelocity) HGPropertyRelease(_spinningOverLifetimeAngularVelocity);
    if (_sizeOverLifetime) HGPropertyRelease(_sizeOverLifetime);
    if (_speedOverLifetime) HGPropertyRelease(_speedOverLifetime);
    if (_speedOverLifetimeRadialAcceleration) HGPropertyRelease(_speedOverLifetimeRadialAcceleration);
    if (_speedOverLifetimeTangentialAcceleration) HGPropertyRelease(_speedOverLifetimeTangentialAcceleration);
    if (_colorOverLifetime) HGPropertyRelease(_colorOverLifetime);
    if (_opacityOverLifetime) HGPropertyRelease(_opacityOverLifetime);
}

- (void)setProperty:(HGPropertyRef)property forKey:(NSString *)propertyKey
{
    // validate that property key is actually of a property type
    HGAssert([[[self class] propertyRefKeys] containsObject:propertyKey], @"Key %@ is not of a HGPropertyRef type.", propertyKey);
    
    // validate the given property option (it should be acceptable for this property key)
    HGAssert([HGParticleSystemPropertyOptionsForPropertyKey(propertyKey) indexOfObjectPassingTest:^BOOL(NSString *properyOptionString, NSUInteger idx, BOOL *stop) {
        return HGPropertyGetOption(property) == HGParticleSystemPropertyOptionFromString(properyOptionString);
    }] != NSNotFound, @"HGPropertyRef value option is invalid for property %@", propertyKey);
    
    [super setValue:CFBridgingRelease(HGPropertyCreateDictionaryRepresentation(property)) forKey:propertyKey];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    id transformedValue = value;
    if ([[[self class] propertyRefKeys] containsObject:key])
    {
        // there is a special case for HGPropertyRef initialization
        HGAssert([value isKindOfClass:NSDictionary.class], @"Cannot set HGPropertyRef value for key %@: %@", key, value);
        HGPropertyRef property = HGPropertyMakeWithDictionary((__bridge CFDictionaryRef)(value));
        transformedValue = CFBridgingRelease(HGPropertyCreateDictionaryRepresentation(property));
    }
    else if ([key isEqualToString:HGGravityPropertyKey])
    {
        // there is a special case for GLKVector2 value, it is encoded as a simple array
        HGAssert([value isKindOfClass:NSArray.class], @"Cannot set GLKVector2 value for key %@: %@", key, value);
        NSArray *array = value;
        GLKVector2 v = GLKVector2Make([array[0] floatValue], [array[1] floatValue]);
        transformedValue = [NSValue valueWithGLKVector2:v];
    }
    [super setValue:transformedValue forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // neither KVC nor NSValue do not support struct pointers, nor GLKVector2 struct
    // so we need to intercept calls and set ivars manually
    if ([self.class.propertyRefKeys containsObject:key])
    {
        NSString *s = [@"_" stringByAppendingString:key];
        Ivar ivar = class_getInstanceVariable(self.class, s.UTF8String);
        //
        // FIXME: check for NULL
        //
        HGPropertyRef * ivarPtr = (HGPropertyRef *)( (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar) );
        *ivarPtr = HGPropertyMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(value));
    }
    else if ([key isEqualToString:HGGravityPropertyKey])
    {
        NSString *s = [@"_" stringByAppendingString:key];
        Ivar ivar = class_getInstanceVariable(self.class, s.UTF8String);
        //
        // FIXME: check for NULL
        //
        GLKVector2 * ivarPtr = (GLKVector2 *)( (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar) );
        [value getValue:ivarPtr];
    }
    else
    {
#if DEBUG
        @try {
            [super setValue:value forUndefinedKey:key];
        }
        @catch (__unused NSException *exception) {
            NSLog (@"Error setting HGParticleSystem property for key: %@, value: %@", key, value);
        }
#else
        [super setValue:value forUndefinedKey:key];
#endif
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([self.class.propertyRefKeys containsObject:key])
    {
        NSString *s = [@"_" stringByAppendingString:key];
        Ivar ivar = class_getInstanceVariable(self.class, s.UTF8String);
        
        HGPropertyRef * ivarPtr = (HGPropertyRef *)( (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar) );
        
        return (__bridge id)HGPropertyCreateDictionaryRepresentation(* ivarPtr);
    }
    return [super valueForUndefinedKey:key];
}

- (void)setParent:(CCNode *)parent
{
    id oldParent = self.parent;
    
    [super setParent:parent];
    
    if (oldParent && parent == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HGParticleSystemDidBecomeAvailableNotification
                                                            object:self];
    }
}

#pragma mark -

- (void)initParticle:(HGParticle *)particle
{
    CCTime elapsed = _elapsed - self.startDelay;
    if (elapsed < 0)
        return;
    
    HGFloat t = elapsed / _duration;
    
    // lifetime
    particle->elapsed = 0.0;
    particle->lifetime = HGPropertyGetFloatValue(_lifetime, t);
    
    // direction
    HGFloat angle = 0.0;
    if (_shapeModule)
    {
        if (_emitterShape == HGParticleSystemEmitterShapeCircle)
        {
            angle = CCRANDOM_0_1() * M_PI * 2.0;
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeOval)
        {
            angle = CCRANDOM_0_1() * M_PI * 2.0;
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeSector)
        {
            angle = CC_DEGREES_TO_RADIANS(_emitterShapeDirection + CCRANDOM_MINUS1_1() * _emitterShapeAngle * .5);
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeRect)
        {
            if (_emitterShapeRandomDirection)
            {
                angle = CCRANDOM_0_1() * M_PI * 2.0;
            }
            else
            {
                angle = CC_DEGREES_TO_RADIANS(_emitterShapeDirection);
            }
        }
    }
    GLKVector2 direction = GLKVector2Make(cos(angle), sin(angle)); // float versions
    
    // speed
    CGFloat startSpeed = HGPropertyGetFloatValue(_startSpeed, t);
    if (_speedOverLifetimeModule)
    {
        if (_speedOverLifetimeMode == HGParticleSystemSpeedModeAcceleration)
        {
            particle->radialAcceleration = HGPropertyGetFloatValue(_speedOverLifetimeRadialAcceleration, t);
            particle->tangentialAcceleration = HGPropertyGetFloatValue(_speedOverLifetimeTangentialAcceleration, t);
        }
    }
    particle->startSpeed = GLKVector2MultiplyScalar(direction, startSpeed);
    particle->speed = particle->startSpeed;
    
    // position
    GLKVector2 position = HGGLKVector2Zero;
    if (_shapeModule)
    {
        if (_emitterShape == HGParticleSystemEmitterShapeCircle)
        {
            if (_emitterShapeRadius > 0)
            {
                if (_emitterShapeBoundary)
                {
                    position = GLKVector2MultiplyScalar(direction, _emitterShapeRadius);
                }
                else
                {
                    position = GLKVector2MultiplyScalar(direction, CCRANDOM_0_1() * _emitterShapeRadius);
                }
            }
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeOval)
        {
            if (_emitterShapeRadius > 0)
            {
                if (_emitterShapeBoundary)
                {
                    position = GLKVector2MultiplyScalar(direction, _emitterShapeRadius);
                }
                else
                {
                    position = GLKVector2MultiplyScalar(direction, CCRANDOM_0_1() * _emitterShapeRadius);
                }
                
                if(_emitterShapeVerticalRatio)
                    position.y *= _emitterShapeVerticalRatio;
            }
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeSector)
        {
            if (_emitterShapeRadius > 0)
            {
                if (_emitterShapeBoundary)
                {
                    position = GLKVector2MultiplyScalar(direction, _emitterShapeRadius);
                }
                else
                {
                    position = GLKVector2MultiplyScalar(direction, CCRANDOM_0_1() * _emitterShapeRadius);
                }
            }
        }
        else if (_emitterShape == HGParticleSystemEmitterShapeRect)
        {
            CGPoint p;
            
            if (_emitterShapeBoundary)
            {
                NSUInteger side = (arc4random() % 4);
                switch (side) {
                    case 0: // top
                        p = ccp( CGRectGetMinX(_emitterRect) + CCRANDOM_0_1() * CGRectGetWidth(_emitterRect),
                                CGRectGetMaxY(_emitterRect));
                        break;
                    case 1: // right
                        p = ccp( CGRectGetMaxX(_emitterRect),
                                CGRectGetMinY(_emitterRect) + CCRANDOM_0_1() * CGRectGetHeight(_emitterRect));
                        break;
                    case 2: // bottom
                        p = ccp( CGRectGetMinX(_emitterRect) + CCRANDOM_0_1() * CGRectGetWidth(_emitterRect),
                                CGRectGetMinY(_emitterRect));
                        break;
                    case 3: // left
                        p = ccp( CGRectGetMinX(_emitterRect),
                                CGRectGetMinY(_emitterRect) + CCRANDOM_0_1() * CGRectGetHeight(_emitterRect));
                        break;
                        
                    default:
                        break;
                }
            }
            else
            {
                p = ccp( CGRectGetMinX(_emitterRect) + CCRANDOM_0_1() * CGRectGetWidth(_emitterRect),
                        CGRectGetMinY(_emitterRect) + CCRANDOM_0_1() * CGRectGetHeight(_emitterRect));
            }
            
            position = GLKVector2Make(p.x, p.y);
        }
    }
    particle->position = position;
    
	// Color
	particle->startColor = HGPropertyGetGLKVector3Value(_startColor, t);
    if (_colorOverLifetimeModule)
    {
        if (HGPropertyGetOption(_colorOverLifetime) == HGParticleSystemPropertyOptionColorRandomRGB)
        {
            GLKVector3 endColor = HGPropertyGetGLKVector3Value(_colorOverLifetime, t);
            particle->colorVelocity = GLKVector3MultiplyScalar(
                                                               GLKVector3Subtract(endColor, particle->startColor),
                                                               1.f/(particle->lifetime?:1.));
        }
        else if (HGPropertyGetOption(_colorOverLifetime) == HGParticleSystemPropertyOptionColorRandomHSV)
        {
            GLKVector3 endColor = HGPropertyGetGLKVector3Value(_colorOverLifetime, t);
            particle->colorVelocity = GLKVector3MultiplyScalar(
                                                               GLKVector3Subtract(endColor, particle->startColor),
                                                               1.f/(particle->lifetime?:1.));
        }
        else
        {
            particle->colorVelocity = HGGLKVector3Zero;
        }
    }
    else
    {
        particle->colorVelocity = HGGLKVector3Zero;
    }
    particle->color = particle->startColor;

    // Opacity
    particle->startOpacity = HGPropertyGetFloatValue(_startOpacity, t);
    if (_opacityOverLifetimeModule)
    {
        if (HGPropertyGetOption(_opacityOverLifetime) == HGParticleSystemPropertyOptionRandomConstants)
        {
            particle->opacityVelocity = (HGPropertyGetFloatValue(_opacityOverLifetime, t) - particle->startOpacity) / (particle->lifetime?:1.);
        }
        else
        {
            particle->opacityVelocity = 0.f;
        }
    }
    else
    {
        particle->opacityVelocity = 0.f;
    }
    particle->opacity = particle->startOpacity;
    
	// size
    particle->startSize = HGPropertyGetFloatValue(_startSize, t);
    if (_sizeOverLifetimeModule)
    {
        if (HGPropertyGetOption(_sizeOverLifetime) == HGParticleSystemPropertyOptionRandomConstants)
        {
            particle->sizeVelocity = (HGPropertyGetFloatValue(_sizeOverLifetime, t) - particle->startSize) / particle->lifetime;
        }
        else
        {
            particle->sizeVelocity = 0.f;
        }
    }
    else
    {
        particle->sizeVelocity = 0.f;
    }
    particle->size = particle->startSize;
    
    particle->rotation = HGPropertyGetFloatValue(_startRotation, t);
#if !__CC_PLATFORM_IOS
    particle->rotation += 180.;
#endif
    particle->startRotation = particle->rotation;
    if (_rotationOverLifetimeModule)
    {
        if (_rotationOverLifetimeMode == HGParticleSystemRotationModeSpeed)
        {
            if (HGPropertyGetOption(_rotationAngularVelocity) == HGParticleSystemPropertyOptionConstant)
            {
                particle->angularVelocity = HGPropertyGetFloatValue(_rotationAngularVelocity, t);
                if (_rotationRandomDirection && ((arc4random() % 2) == 0))
                {
                    particle->angularVelocity *= -1.0;
                }
            }
            if (HGPropertyGetOption(_rotationAngularVelocity) == HGParticleSystemPropertyOptionRandomConstants) {
                particle->angularVelocity = HGPropertyGetFloatValue(_rotationAngularVelocity, t);
                if (_rotationRandomDirection && ((arc4random() % 2) == 0))
                {
                    particle->angularVelocity *= -1.0;
                }
            }
        }
    }
    
	// position
	if( _particlePositionType == CCParticleSystemPositionTypeFree )
    {
		CGPoint p = [self convertToWorldSpace:CGPointZero];
		particle->startPosition = GLKVector2Make(p.x, p.y);
	}
    else if( _particlePositionType == CCParticleSystemPositionTypeRelative )
    {
		CGPoint p = self.position;
		particle->startPosition = GLKVector2Make(p.x, p.y);
	}
    
    // spinning
    if (_spinningOverLifetimeModule)
    {
        particle->spinningAngle = 0.;
        particle->spinningVelocity = HGPropertyGetFloatValue(_spinningOverLifetimeAngularVelocity, 0);
        particle->spinningAxis = GLKVector3Normalize(GLKVector3Make(CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1()));
    }
}


- (NSInteger)priority
{
    // update after action in run!
	return 1;
}

- (BOOL)addParticle
{
	if( [self isFull] )
		return NO;
    
    HGParticle * particle = &_particles[_particleCount];
    [self initParticle:particle];
    _particleCount++;
    
	return YES;
}

- (void)stopSystem
{
	_active = NO;
	_elapsed = _duration + self.startDelay;
	_emitCounter = 0;
}

- (void)resetSystem
{
	_active = YES;
	_elapsed = 0;
    self.startDelay = 0;
    self.actionSpeed = 1.;
    
	for(NSUInteger i = 0; i < _particleCount; ++i)
    {
		HGParticle *p = &_particles[i];
		p->elapsed = p->lifetime;
	}
    
    // force update to remove particles
    BOOL previousVisible = self.visible;
    self.visible = YES;
    [self update:0];
    self.visible = previousVisible;
}

-(void)setVisible:(BOOL)visible
{
    if(self.visible == NO && visible ==  YES && _resetOnVisibilityToggle)
    {
        [self resetSystem];
    }
    
    [super setVisible:visible];
}

- (void)setActionSpeed:(CGFloat)actionSpeed
{
    if (_actionSpeed == actionSpeed)
        return;
    
    _actionSpeed = actionSpeed;
    
    [self cascadeActionSpeed];
}

- (void)cascadeActionSpeed
{
    CGFloat parentActionSpeed = 1.;
    
    if ([_parent respondsToSelector:@selector(displayedActionSpeed)])
    {
        parentActionSpeed = [(id)_parent displayedActionSpeed];
    }
    
    [self updateDisplayedActionSpeed:parentActionSpeed];
}

- (void)updateDisplayedActionSpeed:(CGFloat)parentActionSpeed
{
    _displayedActionSpeed = self.actionSpeed * parentActionSpeed;
}

- (BOOL)isFull
{
    return _particleCount == _totalParticles;
}

#pragma mark ParticleSystem - MainLoop
- (void)update:(CCTime)delta
{
    HG_PROFILING_BEGIN(@"HGParticleSystem::Update");
    
    delta *= _displayedActionSpeed;
    
    CCTime elapsed = _elapsed - self.startDelay;
    if (elapsed < 0)
    {
        _elapsed += delta;

        return;
    }
    
    HGFloat emissionRate = 0.0;
    if (_emissionModule)
    {
        HGFloat t = elapsed / _duration;
        emissionRate = HGPropertyGetFloatValue(_emissionRate, t);
    }
    
	if( _active && emissionRate )
    {
		HGFloat rate = 1.0 / emissionRate;
		
		//issue #1201, prevent bursts of particles, due to too high emitCounter
		if (_particleCount < _maxParticles)
			_emitCounter += delta;
		
		while( _particleCount < _maxParticles && _emitCounter > rate )
        {
			[self addParticle];
			_emitCounter -= rate;
		}
        
		_elapsed += delta;
        
		if(_duration < elapsed)
        {
            if (_looping)
            {
                _elapsed = self.startDelay;
            }
            else
            {
                [self stopSystem];
            }
        }
	}
    
    if (_visible)
    {
        for (NSUInteger i = 0; i < _particleCount;)
        {
            HGParticle *p = &_particles[i];
            
            // life
            p->elapsed += delta;
            
            if( p->elapsed < p->lifetime )
            {
                HGFloat t = p->elapsed / p->lifetime;
                
                GLKVector2 forces = _gravity;
                HGFloat speedMultiplier = 1.0;
                
                if (_speedOverLifetimeModule)
                {
                    if (_speedOverLifetimeMode == HGParticleSystemSpeedModeCurve)
                    {
                        speedMultiplier = HGPropertyGetFloatValue(_speedOverLifetime, t);
                    }
                    else if (_speedOverLifetimeMode == HGParticleSystemSpeedModeAcceleration)
                    {
                        // forces
                        GLKVector2 radial = HGGLKVector2Zero;
                        if (p->position.x || p->position.y)
                        {
                            radial = GLKVector2Normalize(p->position);
                        }
                        GLKVector2 tangential = GLKVector2Make(-radial.y, radial.x);
                        
                        radial = GLKVector2MultiplyScalar(radial, p->radialAcceleration);
                        tangential = GLKVector2MultiplyScalar(tangential, p->tangentialAcceleration);
                        
                        forces = GLKVector2Add(forces, GLKVector2Add(radial, tangential));
                    }
                }
                // apply forces
                p->speed = GLKVector2Add(p->speed,
                                         GLKVector2MultiplyScalar(forces, delta));
                
                // apply speed
                p->position = GLKVector2Add( p->position,
                                            GLKVector2MultiplyScalar(p->speed, speedMultiplier * delta));
                
                if (_rotationOverLifetimeModule)
                {
                    if (_rotationOverLifetimeMode == HGParticleSystemRotationModeSpeed)
                    {
                        if(HGPropertyGetOption(_rotationAngularVelocity) == HGParticleSystemPropertyOptionCurve)
                        {
                            p->angularVelocity = HGPropertyGetFloatValue(_rotationAngularVelocity, t);
                        }
                    }
                    else if (_rotationOverLifetimeMode == HGParticleSystemRotationModeFollow)
                    {
                        // rotation should be dependent on the offset
#if __CC_PLATFORM_IOS
                        HGFloat newRotation = CC_RADIANS_TO_DEGREES(atan2f(- p->speed.x, - p->speed.y));
#else
                        HGFloat newRotation = CC_RADIANS_TO_DEGREES(atan2f(p->speed.x, p->speed.y));
#endif
                        p->rotation = p->startRotation + newRotation;
                    }
                }
                p->rotation += p->angularVelocity * delta;
                
                if (_sizeOverLifetimeModule)
                {
                    if (HGPropertyGetOption(_sizeOverLifetime) == HGParticleSystemPropertyOptionCurve)
                    {
                        p->size = p->startSize * HGPropertyGetFloatValue(_sizeOverLifetime, t);
                    }
                }
                p->size += p->sizeVelocity * delta;
                
                if (_colorOverLifetimeModule)
                {
                    HGParticleSystemPropertyOption option = HGPropertyGetOption(_colorOverLifetime);
                    if (option == HGParticleSystemPropertyOptionGradient)
                    {
                        GLKVector3 color = HGPropertyGetGLKVector3Value(_colorOverLifetime, t);

                        p->color.r = p->startColor.r + color.r;
                        p->color.g = p->startColor.g + color.g;
                        p->color.b = p->startColor.b + color.b;
                    }
                    else if (option == HGParticleSystemPropertyOptionColorRandomHSV)
                    {
                        p->color = GLKVector3Add(p->color,
                                                 GLKVector3MultiplyScalar(p->colorVelocity, delta));
                    }
                    else if (option == HGParticleSystemPropertyOptionColorRandomRGB)
                    {
                        p->color = GLKVector3Add(p->color,
                                                 GLKVector3MultiplyScalar(p->colorVelocity, delta));
                    }
                }
                
                if (_opacityOverLifetimeModule)
                {
                    if (HGPropertyGetOption(_opacityOverLifetime) == HGParticleSystemPropertyOptionCurve)
                    {
                        p->opacity = p->startOpacity * HGPropertyGetFloatValue(_opacityOverLifetime, t);
                    }
                    else
                    {
                        p->opacity += p->opacityVelocity * delta;
                    }
                }
                
                if (_spinningOverLifetimeModule)
                {
                    if ( HGPropertyGetOption(_spinningOverLifetimeAngularVelocity) == HGParticleSystemPropertyOptionCurve)
                    {
                        p->spinningVelocity = HGPropertyGetFloatValue(_spinningOverLifetimeAngularVelocity, t);
                    }
                    if (p->spinningVelocity)
                    {
                        p->spinningAngle += p->spinningVelocity * delta;
                    }
                }
                
                i++;
            }
            else
            {
                if( i != _particleCount-1 )
					_particles[i] = _particles[_particleCount-1];
                
				_particleCount--;
                
				if( _particleCount == 0)
                {
                    if ( _autoRemoveOnFinish )
                    {
                        [self removeFromParent];
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:HGParticleSystemDidFinishNotification
                                                                        object:self];

                    if ( _autoRemoveOnFinish )
                    {
                        return;
                    }
				}
            }
        }
        _transformSystemDirty = NO;
    }
    
    HG_PROFILING_END(@"HGParticleSystem::Update");
}

// pointRect is in Points coordinates.
-(void) initTexCoordsWithRect:(CGRect)pointRect
{
    // convert to Tex coords
    
	CGFloat scale = self.texture.contentScale;
	CGRect rect = CGRectMake(
							 pointRect.origin.x * scale,
							 pointRect.origin.y * scale,
							 pointRect.size.width * scale,
							 pointRect.size.height * scale );
    
	GLfloat wide = [self.texture pixelWidth];
	GLfloat high = [self.texture pixelHeight];
    
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	GLfloat left = (rect.origin.x*2+1) / (wide*2);
	GLfloat bottom = (rect.origin.y*2+1) / (high*2);
	GLfloat right = left + (rect.size.width*2-2) / (wide*2);
	GLfloat top = bottom + (rect.size.height*2-2) / (high*2);
#else
	GLfloat left = rect.origin.x / wide;
	GLfloat bottom = rect.origin.y / high;
	GLfloat right = left + rect.size.width / wide;
	GLfloat top = bottom + rect.size.height / high;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
    
#if __CC_PLATFORM_MAC
    bottom = 1.f - bottom;
    top = 1.f - top;
#endif
    
	for(NSUInteger i=0; i<_maxParticles; i++) {
		_texCoord1[0] = GLKVector2Make(left, bottom);
		_texCoord1[1] = GLKVector2Make(right, bottom);
		_texCoord1[2] = GLKVector2Make(right, top);
		_texCoord1[3] = GLKVector2Make(left, top);
	}
}

-(void) setTexture:(CCTexture *)texture withRect:(CGRect)rect
{
	[super setTexture:texture];
	[self initTexCoordsWithRect:rect];
}

-(void) setTexture:(CCTexture *)texture
{
	CGSize s = [texture contentSize];
	[self setTexture:texture withRect:CGRectMake(0,0, s.width, s.height)];
}

-(void) setSpriteFrame:(CCSpriteFrame *)spriteFrame
{
	HGAssert( CGPointEqualToPoint( spriteFrame.offset , CGPointZero ), @"QuadParticle only supports SpriteFrames with no offsets");
    
	// update texture before updating texture rect
    [self setTexture: spriteFrame.texture withRect:spriteFrame.rect];
}

static inline void OutputParticle(CCRenderBuffer buffer, NSUInteger index, HGParticle * p, GLKVector2 pos, const GLKMatrix4 *transform, GLKVector2 *texCoord1)
{
    int i = (int)index;
	const GLKVector2 zero = {{0, 0}};
	GLKVector4 color = GLKVector4Make(
                                      p->color.r*p->opacity,
                                      p->color.g*p->opacity,
                                      p->color.b*p->opacity,
                                      p->opacity);
    
    //#warning TODO Can do some extra optimization to the vertex transform math.
    //#warning TODO Can pass the particle life and maybe another param using TexCoord2?
    
	float hs = 0.5f*p->size;

    if (p->spinningAngle)
    {
        float r = -CC_DEGREES_TO_RADIANS(p->spinningAngle);
        
        GLKVector4 v[4] = { {-hs, -hs, 0, 1}, {+hs, -hs, 0, 1}, {+hs, +hs, 0, 1}, {-hs, +hs, 0, 1} };
        
        GLKMatrix4 m = *transform;
        m = GLKMatrix4Translate(m, pos.x, pos.y, 0.0);
        m = GLKMatrix4RotateWithVector3(m, r, p->spinningAxis);
        
        GLKMatrix4MultiplyVector4Array(m, v, 4);
        
        CCRenderBufferSetVertex(buffer, 4*i + 0, (CCVertex){v[0], texCoord1[0], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 1, (CCVertex){v[1], texCoord1[1], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 2, (CCVertex){v[2], texCoord1[2], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 3, (CCVertex){v[3], texCoord1[3], zero, color});

    }
	else if( p->rotation )
    {
		float r = -CC_DEGREES_TO_RADIANS(p->rotation);
		float hscr = hs * cosf(r);
		float hssr = hs * sinf(r);
        
		CCRenderBufferSetVertex(buffer, 4*i + 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform,
                                                                                      GLKVector4Make(-hscr - -hssr + pos.x, -hssr + -hscr + pos.y, 0.0f, 1.0f)),
            texCoord1[0], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform,
                                                                                      GLKVector4Make( hscr - -hssr + pos.x,  hssr + -hscr + pos.y, 0.0f, 1.0f)),
            texCoord1[1], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform,
                                                                                      GLKVector4Make( hscr -  hssr + pos.x,  hssr +  hscr + pos.y, 0.0f, 1.0f)),
            texCoord1[2], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform,
                                                                                      GLKVector4Make(-hscr -  hssr + pos.x, -hssr +  hscr + pos.y, 0.0f, 1.0f)),
            texCoord1[3], zero, color});
	} else {
		CCRenderBufferSetVertex(buffer, 4*i + 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x - hs, pos.y - hs, 0.0f, 1.0f)), texCoord1[0], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x + hs, pos.y - hs, 0.0f, 1.0f)), texCoord1[1], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x + hs, pos.y + hs, 0.0f, 1.0f)), texCoord1[2], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x - hs, pos.y + hs, 0.0f, 1.0f)), texCoord1[3], zero, color});
	}
	
	CCRenderBufferSetTriangle(buffer, 2*i + 0, 4*i + 0, 4*i + 1, 4*i + 2);
	CCRenderBufferSetTriangle(buffer, 2*i + 1, 4*i + 0, 4*i + 2, 4*i + 3);
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if(_particleCount == 0) return;
    
    HG_PROFILING_BEGIN(@"HGParticleSystem::Draw  ");
    
	GLKVector2 currentPosition = GLKVector2Make(0.0f, 0.0f);
	if( _particlePositionType == CCParticleSystemPositionTypeFree ){
		CGPoint p = [self convertToWorldSpace:CGPointZero];
		currentPosition = GLKVector2Make(p.x, p.y);
	} else if( _particlePositionType == CCParticleSystemPositionTypeRelative ){
		CGPoint p = self.position;
		currentPosition = GLKVector2Make(p.x, p.y);
	}
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:_particleCount*2 andVertexes:_particleCount*4 withState:self.renderState globalSortOrder:0];
	
    for (NSUInteger i = 0; i<_particleCount; i++)
    {
        HGParticle *particle = _particles + i;
        
		GLKVector2 position = particle->position;
		
		if( _particlePositionType == CCParticleSystemPositionTypeFree || _particlePositionType == CCParticleSystemPositionTypeRelative )
        {
			GLKVector2 diff = GLKVector2Subtract(currentPosition, particle->startPosition);
			position = GLKVector2Subtract(position, diff);
		}
		
		OutputParticle(buffer, i, particle, position, transform, _texCoord1);
    };
    
    HG_PROFILING_END(@"HGParticleSystem::Draw  ");
}

@end
