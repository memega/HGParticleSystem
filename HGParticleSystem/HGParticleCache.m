//
//  HGParticleCache.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleCache.h"

#import "HGParticleSystem.h"

#define HG_DEFAULT_POOL_SIZE 16

typedef NS_ENUM(NSInteger, HGParticlePoolItemState) {
    HGParticlePoolItemStateIdle,
    HGParticlePoolItemStateActive,
    HGParticlePoolItemStateDying,
};

#pragma mark - HGParticlePoolItem

@interface HGParticlePoolItem : NSObject

@property (nonatomic) HGParticlePoolItemState state;
@property (nonatomic) HGParticleSystem* particleSystem;

@end
@implementation HGParticlePoolItem
@end

#pragma mark - HGParticlePool

@interface HGParticlePool ()
{
    NSMutableSet *_pool;
    NSUInteger _availableSystems;
    NSUInteger _capacity;
}

@end

@implementation HGParticlePool

#pragma mark MSParticlePool - Init & dealloc

- (instancetype)initWithFile:(NSString*)path capacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _capacity = capacity;
        _pool = [NSMutableSet setWithCapacity:_capacity];
        for ( NSInteger count = 0; count < _capacity; count ++ ) {
            HGParticlePoolItem *item = [HGParticlePoolItem new];
            item.state = HGParticlePoolItemStateIdle;
            item.particleSystem = [[HGParticleSystem alloc] initWithFile:path];
            [item.particleSystem stopSystem];
            [_pool addObject:item];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(particleSystemDidFinish:)
                                                         name:HGParticleSystemDidFinishNotification
                                                       object:item.particleSystem];
        }
        _availableSystems = _capacity;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //FIXME: release all PS
    [_pool removeAllObjects];
}

#pragma mark MSParticlePool - Getting particles

- (NSUInteger)availableSystems {
    return _availableSystems;
}

- (HGParticleSystem*)particleSystem
{
    __block HGParticlePoolItem *item = nil;
    [_pool enumerateObjectsUsingBlock:^(HGParticlePoolItem *poolItem, BOOL *stop) {
        if (poolItem.state == HGParticlePoolItemStateIdle) {
            item = poolItem;
            
            *stop = YES;
        }
    }];
    if (item) {
        
        _availableSystems--;
        
        item.state = HGParticlePoolItemStateActive;
        [item.particleSystem resetSystem];
        return item.particleSystem;
    }
    return nil;
}

- (void)particleSystemDidFinish:(NSNotification *)notification
{
    NSSet *items = [_pool objectsPassingTest:^BOOL(HGParticlePoolItem *item, BOOL *stop) {
        if (item.particleSystem == notification.object)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (items && items.count == 1)
    {
        [self disposePoolItem:items.anyObject];
    }
}

- (void)disposePoolItem:(HGParticlePoolItem *)poolItem {
    NSLog(@"Disposing a pool item on thread %@", [NSThread currentThread]);
    
    poolItem.state = HGParticlePoolItemStateIdle;
    
    [poolItem.particleSystem stopSystem];
    [poolItem.particleSystem removeFromParent];
    
    _availableSystems++;
}

@end

#pragma mark HGParticleCache

@interface HGParticleCache ()
{
    NSMutableDictionary *_pools;
    
    dispatch_queue_t _dictQueue;
}

@end

@implementation HGParticleCache

+ (HGParticleCache*)sharedParticleCache
{
    static HGParticleCache *sharedInstance;
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

- (HGParticlePool *)addParticleSystemPoolFromFile:(NSString*)path {
    return [self addParticleSystemPoolFromFile:path capacity:HG_DEFAULT_POOL_SIZE];
}

- (HGParticlePool *)addParticleSystemPoolFromFile:(NSString*)path capacity:(NSUInteger)capacity {
    
    path = [path stringByStandardizingPath];
    
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
            NSLog(@"HungryGirls: Couldn't add particles:%@ in MSParticleCache", path);
        }
    }
    
    return pool;
    
}

-(void) removeParticleSystemPoolForKey:(NSString*)name
{
	if( ! name )
		return;
    
	dispatch_sync(_dictQueue, ^{
		[_pools removeObjectForKey:name];
	});
}

#pragma mark ParticleSystemCache - Get
- (HGParticlePool *)particleSystemPoolForKey:(NSString *)key
{
	__block HGParticlePool *pool = nil;
    
	dispatch_sync(_dictQueue, ^{
		pool = [_pools objectForKey:key];
	});
    
	return pool;
}


@end
