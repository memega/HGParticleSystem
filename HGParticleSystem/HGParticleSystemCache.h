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

@interface HGParticleSystemCache : NSObject

+ (instancetype)sharedCache;

- (HGParticleSystem *)addParticleSystemFromFile:(NSString*)name;
- (HGParticleSystem *)addParticleSystemFromFile:(NSString*)name capacity:(NSUInteger)capacity;

- (HGParticleSystem *)particleSystemForKey:(NSString *)key;
- (void)removeParticleSystemForKey:(NSString *)key;

@end
