//
//  HGParticleCache.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleSystemCache.h"

#import "HGParticleSystem.h"

#define HG_DEFAULT_POOL_SIZE 2

typedef NS_ENUM(NSInteger, HGParticlePoolItemState) {
    HGParticlePoolItemStateIdle,
    HGParticlePoolItemStateActive,
    HGParticlePoolItemStateDying,
};

#pragma mark - HGParticlePool

@interface HGParticlePool : NSObject
{
    NSString *_path;
    NSMutableSet *_busySystems;
    NSMutableSet *_availableSystems;
    NSUInteger _capacity;
}

- (instancetype)initWithFile:(NSString*)path capacity:(NSUInteger)capacity;
- (HGParticleSystem *)particleSystem;

@end

@implementation HGParticlePool

#pragma mark MSParticlePool - Init & dealloc

- (instancetype)initWithFile:(NSString*)path capacity:(NSUInteger)capacity {
    self = [super init];
    if (self)
    {
        _path = path;
        _capacity = capacity;
        _availableSystems = [NSMutableSet setWithCapacity:_capacity];
        _busySystems = [NSMutableSet setWithCapacity:_capacity];
        for ( NSInteger count = 0; count < _capacity; count ++ )
        {
            [self addParticleSystemWithFile:path];
        }
    }
    return self;
}

- (void)addParticleSystemWithFile:(NSString *)path
{
    HGParticleSystem *item = [[HGParticleSystem alloc] initWithFile:path];
    [item stopSystem];
    [_availableSystems addObject:item];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(particleSystemDidFinish:)
                                                 name:HGParticleSystemDidFinishNotification
                                               object:item];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //FIXME: release all PS
    [_availableSystems removeAllObjects];
    [_busySystems removeAllObjects];
}

#pragma mark MSParticlePool - Getting particles

- (HGParticleSystem*)particleSystem
{
    if (_availableSystems.count == 0)
    {
        [self addParticleSystemWithFile:_path];
    }
    
    id system = [_availableSystems anyObject];
    [_availableSystems removeObject:system];
    [_busySystems addObject:system];
    return system;
}

- (void)particleSystemDidFinish:(NSNotification *)notification
{
    id system = notification.object;
    if ([_busySystems containsObject:system])
    {
        [_busySystems removeObject:system];
        [_availableSystems addObject:system];
    }
}

@end

#pragma mark HGParticleSystemCache

@interface HGParticleSystemCache ()
{
    NSMutableDictionary *_pools;
    
    dispatch_queue_t _dictQueue;
}

@end

@implementation HGParticleSystemCache

+ (instancetype)sharedCache
{
    static HGParticleSystemCache *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

-(id) init
{
    if( (self=[super init]) ) {
        _pools = [NSMutableDictionary dictionaryWithCapacity:10];
        
		_dictQueue = dispatch_queue_create("com.neobia.particlecachedict", NULL);
    }
    return self;
}

- (NSString*) description
{
	__block NSString *desc = nil;
	dispatch_sync(_dictQueue, ^{
		desc = [NSString stringWithFormat:@"<%@ = %p | num of pools =  %lu | keys: %@>",
                [self class],
                self,
                (unsigned long)[_pools count],
                [_pools allKeys]
                ];
	});
	return desc;
}

-(void) dealloc
{
    _dictQueue = nil;
}

#pragma mark - Particle systems

- (void)addParticleSystemFromFile:(NSString *)name
{
    [self addParticleSystemFromFile:name capacity:HG_DEFAULT_POOL_SIZE];
}

- (void)addParticleSystemFromFile:(NSString *)name capacity:(NSUInteger)capacity
{
    NSString *path = [name stringByStandardizingPath];
    
    __block HGParticlePool *pool = nil;
    
	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
#ifdef __CC_PLATFORM_IOS
	path = [[CCFileUtils sharedFileUtils] removeSuffixFromFile: path];
#endif
	
    dispatch_sync(_dictQueue, ^{
		pool = [_pools objectForKey: path];
	});
    
	if( ! pool ) {
        NSString *fullPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:path];
        
        pool = [[HGParticlePool alloc] initWithFile:fullPath capacity:capacity];
        
        if( pool ){
            dispatch_sync(_dictQueue, ^{
                [_pools setObject: pool forKey:path];
            });
        }else{
            NSLog(@"HGParticleCache: Couldn't add particles: %@", path);
        }
    }
}

- (void)removeParticleSystemForKey:(NSString *)key
{
	if( ! key )
		return;
    
	dispatch_sync(_dictQueue, ^{
		[_pools removeObjectForKey:key];
	});
}

- (HGParticleSystem *)particleSystemForKey:(NSString *)key
{
	__block HGParticlePool *pool = nil;
    
	dispatch_sync(_dictQueue, ^{
		pool = [_pools objectForKey:key];
	});
    
    return pool.particleSystem;
}

@end
