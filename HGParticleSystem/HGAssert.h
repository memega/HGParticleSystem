//
//  HGAssert.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#ifndef HGParticleSystem_HGAssert_h
#define HGParticleSystem_HGAssert_h

#if DEBUG
#define HGAssert(expression, ...) \
    do { \
        if(!(expression)) { \
            NSLog(@"Assertion failure: %s in %s on line %s:%d. %@", #expression, __func__, __FILE__, __LINE__, [NSString stringWithFormat: @"" __VA_ARGS__]); \
            abort(); \
        } \
    } while(0)
#else
#define HGAssert(expression, ...) \
    do { \
        if(!(expression)) { \
            NSLog(@"Assertion failure: %s in %s on line %s:%d. %@", #expression, __func__, __FILE__, __LINE__, [NSString stringWithFormat: @"" __VA_ARGS__]); \
        } \
    } while(0)
#endif

#define HGMissingKey(condition, key) HGAssert(!(condition), @"Missing %@ key", key);
#define HGMissingValue(value, key) HGAssert((value), @"Missing value for %@", key);

#endif
