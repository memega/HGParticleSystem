//
//  CGFloatAdditions.c
//  hungryGirls
//
//  Created by Yuriy Panfyorov on 04/07/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "CGFloatAdditions.h"

CGFloat hg_roundCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return round(x);
#else
    return roundf(x);
#endif
}

CGFloat hg_powCGFloat(CGFloat x, CGFloat y) {
#if CGFLOAT_IS_DOUBLE
    return pow(x, y);
#else
    return powf(x, y);
#endif
}

CGFloat hg_sqrtCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return sqrt(x);
#else
    return sqrtf(x);
#endif
}

CGFloat hg_cbrtCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return cbrt(x);
#else
    return cbrtf(x);
#endif
}

CGFloat hg_acosCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return acos(x);
#else
    return acosf(x);
#endif
}

CGFloat hg_cosCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return cos(x);
#else
    return cosf(x);
#endif
}

CGFloat hg_sinCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return sin(x);
#else
    return sinf(x);
#endif
}

CGFloat hg_nextafterCGFloat(CGFloat x, CGFloat y) {
#if CGFLOAT_IS_DOUBLE
    return nextafter(x, y);
#else
    return nextafterf(x, y);
#endif
}

long int hg_lroundCGFloat(CGFloat x ) {
#if CGFLOAT_IS_DOUBLE
    return lround(x);
#else
    return lroundf(x);
#endif
}

CGFloat hg_truncCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return trunc(x);
#else
    return truncf(x);
#endif
}

CGFloat hg_fabsCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return fabs(x);
#else
    return fabsf(x);
#endif
}

@implementation NSNumber (CGFloatAdditions)

- (CGFloat)hg_CGFloatValue {
#if CGFLOAT_IS_DOUBLE
    return [self doubleValue];
#else
    return [self floatValue];
#endif
}

@end

@implementation NSDictionary (CGFloatAdditions)

- (CGFloat)hg_CGFloatForKey:(NSString *)key {
    id v = [self objectForKey:key];
    if ([v isKindOfClass:NSNumber.class]) {
        return [v doubleValue];
    }
    return NAN;
}

@end