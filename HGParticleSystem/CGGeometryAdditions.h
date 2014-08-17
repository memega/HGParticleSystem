//
//  CGGeometryAdditions.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 28/07/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"
#import "CGFloatAdditions.h"

FOUNDATION_EXPORT CGPoint const HGCGPointNone;
FOUNDATION_EXPORT CGPoint const HGCGPointOne;
FOUNDATION_EXPORT CGSize const HGCGSizeNone;

static inline HGRect HGRectApplyInsets(HGRect rect, HGEdgeInsets insets)
{
    HGRect result = rect;
    result.origin.x += insets.left;
    result.origin.y += insets.bottom;
    result.size.width -= (insets.left + insets.right);
    result.size.height -= (insets.top + insets.bottom);
    return result;
}

static inline CGPoint HGCGPointClamp(CGPoint point, CGPoint min, CGPoint max)
{
    return CGPointMake(hg_clampCGFloat(point.x, min.x, max.x),
                       hg_clampCGFloat(point.y, min.y, max.y));
}

static inline CGFloat HGCGFloatLerp(CGFloat a, CGFloat b, CGFloat ratio)
{
    return a + (b - a) * ratio;
}

static inline CGPoint HGCGPointInvert(CGPoint point)
{
    return CGPointMake(- point.x, - point.y);
}

static inline CGFloat HGCGPointLengthSquared(CGPoint point)
{
    return point.x * point.x + point.y * point.y;
}

static inline CGFloat HGCGPointLength(CGPoint point)
{
    return hg_sqrtCGFloat(HGCGPointLengthSquared(point));
}

static inline CGPoint HGCGPointNormalize(CGPoint point)
{
    CGFloat pointLength = HGCGPointLength(point);
    return CGPointMake(point.x / pointLength, point.y / pointLength);
}

static inline CGPoint HGCGPointScale(CGPoint point, CGFloat scale)
{
    return CGPointMake(point.x * scale, point.y * scale);
}

static inline CGPoint HGCGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

static inline CGPoint HGCGPointSubtract(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

static inline CGPoint HGCGPointLerp(CGPoint p1, CGPoint p2, CGFloat ratio)
{
    return CGPointMake(HGCGFloatLerp(p1.x, p2.x, ratio), HGCGFloatLerp(p1.y, p2.y, ratio));
}

static inline CGPoint HGCGPointNormalized(CGPoint point, CGSize size)
{
    return CGPointMake(point.x / size.width, point.y / size.height);
}

static inline CGPoint HGCGPointDenormalized(CGPoint point, CGSize size)
{
    return CGPointMake(point.x * size.width, point.y * size.height);
}

typedef struct HGBezierCurve
{
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    CGPoint p4;
} HGBezierCurve;

static inline HGBezierCurve HGBezierCurveMake(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4)
{
    HGBezierCurve curve; curve.p1 = p1; curve.p2 = p2; curve.p3 = p3; curve.p4 = p4; return curve;
}

static inline CGFloat HGBezierCurveInterpolate(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d)
{
    CGFloat t2 = t * t;
    CGFloat t3 = t2 * t;
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3;
}

static inline CGPoint HGBezierCurveInterpolatePoint(CGFloat t, HGBezierCurve curve)
{
    return CGPointMake(
                       HGBezierCurveInterpolate(t, curve.p1.x, curve.p2.x, curve.p3.x, curve.p4.x),
                       HGBezierCurveInterpolate(t, curve.p1.y, curve.p2.y, curve.p3.y, curve.p4.y));
}

FOUNDATION_EXPORT size_t HGBezierCurveSplit(const CGFloat t, const HGBezierCurve curve, HGBezierCurve **curves);
// returns count of possible t values, putting them into roots variable if provided.
// if specified, roots must be at least 3 CGFloats long
FOUNDATION_EXPORT size_t HGBezierCurveSolveX(const CGFloat x, const HGBezierCurve curve, CGFloat roots[]);

@interface NSDictionary (CGGeometryAdditions)

- (CGPoint)CGPointForKey:(NSString *)key;
- (CGSize)CGSizeForKey:(NSString *)key;

@end
