//
//  CGFloatAdditions.h
//  hungryGirls
//
//  Created by Yuriy Panfyorov on 04/07/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#ifndef hungryGirls_CGFloatAdditions_h
#define hungryGirls_CGFloatAdditions_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifndef HGCGFLOAT_EPSILON
#if CGFLOAT_IS_DOUBLE
#define HGCGFLOAT_EPSILON DBL_EPSILON
#else
#define HGCGFLOAT_EPSILON FLT_EPSILON
#endif
#endif

FOUNDATION_EXPORT CGFloat hg_acosCGFloat(CGFloat x);
FOUNDATION_EXPORT CGFloat hg_cosCGFloat(CGFloat x);
FOUNDATION_EXPORT CGFloat hg_sinCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_powCGFloat(CGFloat x, CGFloat y);

FOUNDATION_EXPORT CGFloat hg_fabsCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_sqrtCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_cbrtCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_nextafterCGFloat(CGFloat x, CGFloat y);

FOUNDATION_EXPORT long int hg_lroundCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_truncCGFloat(CGFloat x);

FOUNDATION_EXPORT CGFloat hg_roundCGFloat(CGFloat x);

static inline CGFloat hg_clampCGFloat(CGFloat value, CGFloat min_inclusive, CGFloat max_inclusive)
{
    if (min_inclusive > max_inclusive) {
        CGFloat temp = min_inclusive; min_inclusive = max_inclusive; max_inclusive = temp;
    }
    return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}

#endif

@interface NSNumber (CGFloatAdditions)

- (CGFloat)hg_CGFloatValue;

@end

@interface NSDictionary (CGFloatAdditions)

- (CGFloat)hg_CGFloatForKey:(NSString *)key;

@end
