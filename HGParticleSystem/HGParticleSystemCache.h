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

@class HGParticleSystem;

/**
 *  A container that stores pre-populated HGParticleSystem instances for further reuse.
 */
@interface HGParticleSystemCache : NSObject

/**
 *  Returns the singleton cache instance.
 *
 *  @return The cache instance is created during the first method invocation.
 */
+ (instancetype)sharedCache;

/**
 *  Parses the .hgps file and loads into memory a number of pre-populated instances of HGParticleSystem.
 *
 *  @param name Path of a .hgps file.
 */
- (void)addParticleSystemFromFile:(NSString*)name;

/**
 *  Returns an instance of HGParticleSystem.
 *
 *  @param key Path of a .hgps file.
 *
 *  @return An available HGParticleSystem instance. If particle system with the given name has not been loaded yet, returns nil. If there are no pre-populated instances available, returns nil.
 */
- (HGParticleSystem *)particleSystemForKey:(NSString *)key;

/**
 *  Returns an instance of HGParticleSystem.
 *
 *  @param key                      Path of a .hgps file.
 *  @param increaseCapacityIfNeeded Set to YES, if cache should load a new particle system instance when cache is depleted.
 *
 *  @return An available HGParticleSystem instance. If particle system with the given name has not been loaded yet, returns nil. If there are no pre-populated instances available and increaseCapacityIfNeeded equals YES, loads a new instance and returns it.
 */
- (HGParticleSystem *)particleSystemForKey:(NSString *)key increaseCapacityIfNeeded:(BOOL)increaseCapacityIfNeeded;

/**
 *  Removes all instances for the given key from the cache.
 *
 *  @param key Path of a .hgps file.
 */
- (void)removeParticleSystemForKey:(NSString *)key;

@end
