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

@interface HGParticlePool : NSObject

- (instancetype)initWithFile:(NSString*)path capacity:(NSUInteger)capacity;

- (NSUInteger)availableSystems;

- (HGParticleSystem *)particleSystem;

@end

@interface HGParticleCache : NSObject

+ (instancetype)sharedParticleCache;

-(HGParticlePool *)addParticleSystemPoolFromFile:(NSString*)name;
-(HGParticlePool *)addParticleSystemPoolFromFile:(NSString*)name capacity:(NSUInteger)capacity;

-(void) removeParticleSystemPoolForKey:(NSString*)name;
-(HGParticlePool *)particleSystemPoolForKey:(NSString *)key;

@end
