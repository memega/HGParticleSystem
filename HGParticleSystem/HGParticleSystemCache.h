/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
