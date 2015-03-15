//
//  HGParticleSystem.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 08/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#if defined(__has_include)
#if __has_include("cocos2d.h")
#import "cocos2d.h"
#else
#import "HGCocos2D.h"
#endif
#else
#import "cocos2d.h"
#endif

#define HG_DEBUG_PROFILING 0

#import "HGParticleSystemKeys.h"
#import "HGParticleSystemProperty.h"

#pragma mark - Notification

// sent when a non-looped particle system finishes
FOUNDATION_EXPORT NSString * const HGParticleSystemDidFinishNotification;
// sent when parent property becomes nil.
// note that cache would mark this system as available and it should not be reused again.
FOUNDATION_EXPORT NSString * const HGParticleSystemDidBecomeAvailableNotification;

#pragma mark - HGParticleSystem

@interface HGParticleSystem : CCNode

- (instancetype)initWithFile:(NSString *)plistFile;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/** True if particle system active. */
@property (nonatomic,readonly) BOOL active;

/** Quantity of particles that are being simulated at the moment. */
@property (nonatomic,readonly) NSUInteger particleCount;

/** True will remove particle system on completition. */
@property (nonatomic,readwrite) BOOL autoRemoveOnFinish;

/** True particle system will reset upon visibility  toggling to True. */
@property (nonatomic,readwrite) BOOL resetOnVisibilityToggle;

/**
 *  Set particle system texture using specified texture and texture coords value.
 *
 *  @param texture Texture.
 *  @param rect    Texture coords.
 */
-(void) setTexture:(CCTexture *)texture withRect:(CGRect)rect;

- (void)stopSystem;
- (void)resetSystem;

@property (nonatomic) CCTime startDelay;

@property (nonatomic) CGFloat actionSpeed;
@property (nonatomic) CGFloat displayedActionSpeed;

- (void)setProperty:(HGPropertyRef)property forKey:(NSString *)propertyKey;

@end
