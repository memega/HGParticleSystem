//
//  HGParticleCache.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleSystemCache.h"

#import "HGParticleSystem.h"

static NSUInteger const HGParticleSystemCacheDefaultCapacity = 16;

#pragma mark - HGParticlePool

@interface HGParticlePool : NSObject
{
    NSString *_path;
    NSMutableSet *_busySystems;
    NSMutableSet *_availableSystems;
    NSUInteger _capacity;
}

- (instancetype)initWithFile:(NSString*)path capacity:(NSUInteger)capacity;
- (HGParticleSystem *)getAvailableParticleSystemAndIncreaseCapacity:(BOOL)increaseCapacity;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(particleSystemDidBecomeAvailable:)
                                                 name:HGParticleSystemDidBecomeAvailableNotification
                                               object:item];
    
    [_availableSystems addObject:item];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //FIXME: release all PS
    [_availableSystems removeAllObjects];
    [_busySystems removeAllObjects];
}

#pragma mark MSParticlePool - Getting particles

- (HGParticleSystem*)getAvailableParticleSystemAndIncreaseCapacity:(BOOL)increaseCapacity
{
    if (_availableSystems.count == 0)
    {
        if (increaseCapacity)
        {
            [self addParticleSystemWithFile:_path];
        }
        else
        {
            return nil;
        }
    }
    
    id system = [_availableSystems anyObject];
    [_availableSystems removeObject:system];
    [_busySystems addObject:system];
    [system resetSystem];
    return system;
}

- (void)particleSystemDidBecomeAvailable:(NSNotification *)notification
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
    [self addParticleSystemFromFile:name
                           capacity:HGParticleSystemCacheDefaultCapacity];
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
    return [self particleSystemForKey:key increaseCapacityIfNeeded:NO];
}

- (HGParticleSystem *)particleSystemForKey:(NSString *)key increaseCapacityIfNeeded:(BOOL)increaseCapacityIfNeeded
{
	__block HGParticlePool *pool = nil;
    
	dispatch_sync(_dictQueue, ^{
		pool = [_pools objectForKey:key];
	});
    
    return [pool getAvailableParticleSystemAndIncreaseCapacity:increaseCapacityIfNeeded];
}

@end
