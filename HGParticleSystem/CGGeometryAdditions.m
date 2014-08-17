//
//  CGGeometryAdditions.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 28/07/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "CGGeometryAdditions.h"

CGPoint const HGCGPointOne = (CGPoint){1., 1.};
CGPoint const HGCGPointNone = (CGPoint){ CGFLOAT_MAX, CGFLOAT_MAX };
CGSize const HGCGSizeNone = (CGSize){ CGFLOAT_MAX, CGFLOAT_MAX };

#define CGFloatIsZero(x) ((x)>-HGCGFLOAT_EPSILON && (x)<HGCGFLOAT_EPSILON)

#pragma mark - Bezier split

size_t HGBezierCurveSplit(const CGFloat t, const HGBezierCurve curve, HGBezierCurve **curves)
{
    //    // lookup table resolution
    //    int L = points.length;
    //    order = L-1;
    //    LUT_resolution = 1 + (int) (400 * log(order)/log(4));
    
    // http://pomax.github.io/bezierinfo/#splitting
    // http://en.wikipedia.org/wiki/De_Casteljau's_algorithm
    
    // 3rd degree polynomial, two approximations
    
    CGFloat tt = hg_clampCGFloat(t, 0., 1.);
    
    CGPoint p5 = HGCGPointLerp(curve.p1, curve.p2, tt);
    CGPoint p6 = HGCGPointLerp(curve.p2, curve.p3, tt);
    CGPoint p7 = HGCGPointLerp(curve.p3, curve.p4, tt);
    
    CGPoint p8 = HGCGPointLerp(p5, p6, tt);
    CGPoint p9 = HGCGPointLerp(p6, p7, tt);
    
    CGPoint pt = HGCGPointLerp(p8, p9, tt);
    
    HGBezierCurve *splitCurves = calloc(2, sizeof(HGBezierCurve));
    
    if (splitCurves)
    {
        splitCurves[0].p1 = curve.p1;
        splitCurves[0].p2 = p5;
        splitCurves[0].p3 = p8;
        splitCurves[0].p4 = pt;
        
        splitCurves[1].p1 = pt;
        splitCurves[1].p2 = p9;
        splitCurves[1].p3 = p7;
        splitCurves[1].p4 = curve.p4;
        
        *curves = splitCurves;
        
        return 2;
    }

    return 0; // memory problem
}

#pragma mark - Bezier solving

size_t solveQuadraticEquation(const CGFloat a, const CGFloat b, const CGFloat c, CGFloat roots[])
{
    if (roots == NULL)
        return 0;
    
    CGFloat d = b * b - 4 * a * c;
    
    if (d < 0)
        return 0;
    
    roots[0] = (- b + hg_sqrtCGFloat(d)) / 2. / a;
    roots[1] = (- b - hg_sqrtCGFloat(d)) / 2. / a;
    
    return 2;
}

size_t solveCubicEquation(const CGFloat a, const CGFloat b, const CGFloat c, const CGFloat d, CGFloat roots[])
{
    // http://tog.acm.org/resources/GraphicsGems/gemsiv/vec_mat/ray/solver.c
    
    if (roots == NULL)
        return 0;
    
    if (CGFloatIsZero(a))
        return solveQuadraticEquation(b, c, d, roots);
    
    NSUInteger resultCount = 0;
    
    // normalize the equation:x ^ 3 + Ax ^ 2 + Bx  + C = 0
    CGFloat A = b/a;
    CGFloat B = c/a;
    CGFloat C = d/a;
    
    // substitute x = y - A / 3 to eliminate the quadric term: x^3 + px + q = 0
    CGFloat p = (B - A * A / 3.0) / 3.0;
    CGFloat q = (A * A * A * 2.0 / 27.0 - A * B / 3.0 + C) / 2.0;
    
    // use Cardano's formula
    CGFloat D = q * q + p * p * p;
    
    if (CGFloatIsZero(D))
    {
        if (CGFloatIsZero(q))
        {
            // one triple solution
            roots[0] = 0.0;
            resultCount = 1;
        }
        else
        {
            CGFloat u = hg_cbrtCGFloat(-q);
            roots[0] = 2.0 * u;
            roots[1] = - u;
            resultCount = 2;
        }
    }
    else
    {
        if (D < 0.0)
        {
            // casus irreductibilis: three real solutions
            CGFloat phi = hg_acosCGFloat(-q / hg_sqrtCGFloat(- p * p * p)) / 3.0;
            CGFloat t = 2.0 * hg_sqrtCGFloat(-p);
            
            roots[0] = t * hg_cosCGFloat(phi);
            roots[1] = -t * hg_cosCGFloat(phi + M_PI / 3.0);
            roots[2] = -t * hg_cosCGFloat(phi - M_PI / 3.0);
            
            resultCount = 3;
        }
        else
        {
            // one real solution
            CGFloat u = hg_cbrtCGFloat(hg_sqrtCGFloat(D)+ hg_fabsCGFloat(q));
            if (q > 0.0)
            {
                roots[0] = - u + p / u ;
            }
            else
            {
                roots[0] = u - p / u;
            }

            resultCount = 1;
        }
    }
    
    // resubstitute
    CGFloat substitute = A / 3.0;
    for (NSUInteger i = 0; i < resultCount; i++)
        roots[i] -= substitute;
    
    return resultCount;
}

size_t HGBezierCurveSolveX(const CGFloat x, const HGBezierCurve curve, CGFloat roots[])
{
    // http://math.stackexchange.com/questions/527005/find-value-of-t-at-a-point-on-a-cubic-bezier-curve
    // http://cagd.cs.byu.edu/~557/text/ch17.pdf
    // http://www.helioscorner.com/numerical-solution-of-a-cubic-equation-which-is-the-fastest-way/
    // http://stackoverflow.com/questions/7348009/y-coordinate-for-a-given-x-cubic-bezier
    // used solver from: http://tog.acm.org/resources/GraphicsGems/gemsiv/vec_mat/ray/solver.c

    CGFloat pp0 = curve.p1.x - x;
    CGFloat pp1 = curve.p2.x - x;
    CGFloat pp2 = curve.p3.x - x;
    CGFloat pp3 = curve.p4.x - x;
    
    CGFloat a = pp3 - 3. * pp2 + 3. * pp1 - pp0;
    CGFloat b = 3. * pp2 - 6. * pp1 + 3. * pp0;
    CGFloat c = 3. * pp1 - 3. * pp0;
    CGFloat d = pp0;

    CGFloat cubicRoots[3];
    size_t cubicResults = solveCubicEquation(a, b, c, d, cubicRoots);

    NSUInteger resultNumber = 0;
    for (NSUInteger i = 0; i<cubicResults; i++) {
        if (cubicRoots[i] >= 0. && cubicRoots[i] <= 1.)
        {
            roots[resultNumber++] = cubicRoots[i];
        }
    }
    return resultNumber;
}


@implementation NSDictionary(CGGeometryAdditions)

- (CGPoint)CGPointForKey:(NSString *)key {
    CGPoint p = HGCGPointNone;
    id v = [self objectForKey:key];
    if ([v isKindOfClass:NSDictionary.class]) {
        id n = [v objectForKey:@"x"];
        if ([n isKindOfClass:NSNumber.class]) {
            p.x = [n doubleValue];
        }
        n = [v objectForKey:@"y"];
        if ([n isKindOfClass:NSNumber.class]) {
            p.y = [n doubleValue];
        }
    }
    return p;
}

- (CGSize)CGSizeForKey:(NSString *)key {
    CGSize s = HGCGSizeNone;
    id v = [self objectForKey:key];
    if ([v isKindOfClass:NSDictionary.class]) {
        id n = [v objectForKey:@"width"];
        if ([n isKindOfClass:NSNumber.class]) {
            s.width = [n doubleValue];
        }
        n = [v objectForKey:@"height"];
        if ([n isKindOfClass:NSNumber.class]) {
            s.height = [n doubleValue];
        }
    }
    return s;
}

@end