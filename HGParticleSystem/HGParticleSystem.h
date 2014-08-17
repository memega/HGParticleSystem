//
//  HGParticleSystem.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 08/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#if __has_include("cocos2d.h")
#import "cocos2d.h"
#else
#import "HGCocos2D.h"
#endif

#define HG_DEBUG_PROFILING 0

#pragma mark - Notification

FOUNDATION_EXPORT NSString * const HGParticleSystemDidFinishNotification;

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


@end
