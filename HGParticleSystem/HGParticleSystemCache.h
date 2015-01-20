//
//  HGParticleCache.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
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

#import "HGParticleSystem.h"

@interface HGParticleSystemCache : NSObject

+ (instancetype)sharedCache;

- (void)addParticleSystemFromFile:(NSString*)name;

- (HGParticleSystem *)particleSystemForKey:(NSString *)key;
- (HGParticleSystem *)particleSystemForKey:(NSString *)key increaseCapacityIfNeeded:(BOOL)increaseCapacityIfNeeded;

- (void)removeParticleSystemForKey:(NSString *)key;

@end
