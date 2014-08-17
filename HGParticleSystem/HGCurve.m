//
//  HGCurve.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 02/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGCurve.h"

#import "HGAssert.h"
#import "CGGeometryAdditions.h"
#import "HGLookupTable.h"

#pragma mark - Point

@interface HGCurvePoint ()

- (instancetype)initWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl rightControlOffset:(CGPoint)rightControl;

@end

@implementation HGCurvePoint

+ (instancetype)pointWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *positionValue = dictionary[@"position"];
    if (positionValue == nil)
        return nil;
    
    CGPoint position;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)positionValue, &position);
    
    CGPoint leftControlOffset = HGCGPointNone;
    NSDictionary *leftControlOffsetValue = dictionary[@"leftControlOffset"];
    if (leftControlOffsetValue)
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)leftControlOffsetValue, &leftControlOffset);
    
    CGPoint rightControlOffset = HGCGPointNone;
    NSDictionary *rightControlOffsetValue = dictionary[@"rightControlOffset"];
    if (rightControlOffsetValue)
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)rightControlOffsetValue, &rightControlOffset);
    
    return [self pointWithPosition:position leftControlOffset:leftControlOffset rightControlOffset:rightControlOffset];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    dictionary[@"position"] = (__bridge NSDictionary *)CGPointCreateDictionaryRepresentation(self.position);
    
    if (self.hasLeftControl)
        dictionary[@"leftControlOffset"] = (__bridge NSDictionary *)CGPointCreateDictionaryRepresentation(self.leftControlOffset);
    
    if (self.hasRightControl)
        dictionary[@"rightControlOffset"] = (__bridge NSDictionary *)CGPointCreateDictionaryRepresentation(self.rightControlOffset);
    
    return dictionary;
}

- (NSString *)description
{
    const int precision = 2;
#define HG__FORMAT_CGFLOAT_MAX(value) (value == CGFLOAT_MAX ? NAN : value)
    return [NSString stringWithFormat:@"{ (%.*f,%.*f)←(%.*f,%.*f)→(%.*f,%.*f) }",
            precision, HG__FORMAT_CGFLOAT_MAX(self.leftControlOffset.x), precision, HG__FORMAT_CGFLOAT_MAX(self.leftControlOffset.y),
            precision, HG__FORMAT_CGFLOAT_MAX(self.position.x), precision, HG__FORMAT_CGFLOAT_MAX(self.position.y),
            precision, HG__FORMAT_CGFLOAT_MAX(self.rightControlOffset.x), precision, HG__FORMAT_CGFLOAT_MAX(self.rightControlOffset.y)
            ];
#undef HG__FORMAT_CGFLOAT_MAX
}

- (BOOL)isEqual:(id)object
{
    if (self.class != [object class])
        return NO;
    
    HGCurvePoint *other = (HGCurvePoint *)object;
    if (! CGPointEqualToPoint(self.position, other.position))
        return NO;
    
    if (! CGPointEqualToPoint(self.leftControlOffset, other.leftControlOffset))
        return NO;
    
    if (! CGPointEqualToPoint(self.rightControlOffset, other.rightControlOffset))
        return NO;
    
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] pointWithPosition:self.position
                         leftControlOffset:self.leftControlOffset
                        rightControlOffset:self.rightControlOffset];
}

+ (instancetype)pointWithPosition:(CGPoint)position
{
    return [self pointWithPosition:position leftControlOffset:HGCGPointNone rightControlOffset:HGCGPointNone];
}

+ (instancetype)pointWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl
{
    return [self pointWithPosition:position leftControlOffset:leftControl rightControlOffset:HGCGPointNone];
}

+ (instancetype)pointWithPosition:(CGPoint)position rightControlOffset:(CGPoint)rightControl
{
    return [self pointWithPosition:position leftControlOffset:HGCGPointNone rightControlOffset:rightControl];
}

+ (instancetype)pointWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl rightControlOffset:(CGPoint)rightControl
{
    return [[self alloc] initWithPosition:position leftControlOffset:leftControl rightControlOffset:rightControl];
}

// designated initializer
- (instancetype)initWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl rightControlOffset:(CGPoint)rightControl
{
    self = [super init];
    if (self) {
        _position = position;
        _leftControlOffset = leftControl;
        _rightControlOffset = rightControl;
    }
    return self;
}

// accepts normalized values
- (void)setLeftControlPointPosition:(CGPoint)position
{
    _leftControlOffset = CGPointMake(position.x - _position.x, position.y - _position.y);
    
    // TODO: check type here
    if (CGPointEqualToPoint(_rightControlOffset, HGCGPointNone)) {
    }
    else
    {
        // rotate point without changing its length
        CGFloat length = HGCGPointLength(_rightControlOffset);
        _rightControlOffset = HGCGPointScale(HGCGPointNormalize(HGCGPointInvert(_leftControlOffset)), length);
    }
}

- (CGPoint)leftControlPosition
{
    if (CGPointEqualToPoint(_leftControlOffset, HGCGPointNone))
        return _position;
    
    return HGCGPointAdd(_position, _leftControlOffset);
}

- (BOOL)hasLeftControl
{
    return !CGPointEqualToPoint(_leftControlOffset, HGCGPointNone);
}

// accepts normalized values
- (void)setRightControlPointPosition:(CGPoint)position
{
    _rightControlOffset = CGPointMake(position.x - _position.x, position.y - _position.y);
    
    // TODO: check type here
    if (CGPointEqualToPoint(_leftControlOffset, HGCGPointNone)) {
    }
    else
    {
        // rotate point without changing its length
        CGFloat length = HGCGPointLength(_leftControlOffset);
        _leftControlOffset = HGCGPointScale(HGCGPointNormalize(HGCGPointInvert(_rightControlOffset)), length);
    }
}

- (CGPoint)rightControlPosition
{
    if (CGPointEqualToPoint(_rightControlOffset, HGCGPointNone))
        return _position;
    
    return HGCGPointAdd(_position, _rightControlOffset);
}

- (BOOL)hasRightControl
{
    return !CGPointEqualToPoint(_rightControlOffset, HGCGPointNone);
}

@end

#pragma mark - Curve

@implementation HGCurve

- (BOOL)isEqual:(id)object
{
    if (self.class != [object class])
        return NO;
    
    HGCurve *other = (HGCurve *)object;

    if (self.multiplier != other.multiplier)
        return NO;
    
    if (self.mirroredRange != other.mirroredRange)
        return NO;
    
    if (![self.points isEqualToArray:other.points])
        return NO;
    
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    HGCurve *copy = [[[self class] alloc] init];
    
    NSMutableArray *points = NSMutableArray.array;
    for (NSInteger i = 0; i<self.points.count; i++)
    {
        [points addObject:[self.points[i] copy]];
    }
    copy->_multiplier = self.multiplier;
    copy->_mirroredRange = self.mirroredRange;
    copy->_points = points;
    return copy;
}

- (HGCurve *)curveWithMultiplier:(CGFloat)multiplier mirrored:(BOOL)mirrored
{
    HGCurve *copy = [self copy];
    copy->_multiplier = multiplier;
    copy->_mirroredRange = mirrored;
    return copy;
}

- (HGCurve *)curveWithPoints:(NSArray *)points
{
    HGCurve *copy = [self copy];
    copy->_points = points;
    return copy;
}

+ (instancetype)curveByNormalizingPoint:(CGPoint)point
{
    CGFloat multiplier = point.y > 1. ? point.y : 1.;

    return [[self alloc] initWithPoints:@[[HGCurvePoint pointWithPosition:CGPointMake(hg_clampCGFloat(point.x, 0., 1.), point.y / multiplier)]]
                             multiplier:multiplier
                               mirrored:NO];
}

+ (instancetype)curveWithPoints:(NSArray *)points multiplier:(CGFloat)multiplier
{
    return [[self alloc] initWithPoints:points multiplier:multiplier mirrored:NO];
}

- (instancetype)init
{
    return [self initWithPoints:@[] multiplier:1. mirrored:NO];
}

// designated
- (instancetype)initWithPoints:(NSArray *)points multiplier:(CGFloat)multiplier mirrored:(BOOL)mirrored
{
    self = [super init];
    if (self)
    {
        _points = points;
        _multiplier = multiplier;
        _mirroredRange = mirrored;
    }
    return self;
}

- (void)removePoint:(HGCurvePoint *)point
{
    NSInteger index = [self.points indexOfObject:point];
    
    if (index == NSNotFound) // something weird
        return;
    
    NSMutableArray *points = [self mutableArrayValueForKey:@"points"];
    [points removeObject:point];
    
    if (index == 0)
    {
        HGCurvePoint *newFirstPoint = points.firstObject;
        newFirstPoint.leftControlOffset = HGCGPointNone;
    }
    
    if (index == points.count)
    {
        HGCurvePoint *newLastPoint = points.lastObject;
        newLastPoint.rightControlOffset = HGCGPointNone;
    }
}

- (HGCurvePoint *)insertPointAtPosition:(CGPoint)position
{
    return [self insertPointAtPosition:position tolerance:CGPointMake(0.05, 0.05)];
}

- (HGCurvePoint *)insertPointAtPosition:(CGPoint)position tolerance:(CGPoint)tolerance
{
    if (self.points.count == 0)
        return nil;
    
    HGCurvePoint *p2;

    //
    // clicked on the line to the left of the first point.
    //
    p2 = self.points.firstObject;
    if (p2.position.x > position.x)
    {
        if (position.x < 0.)
            return nil;
        
        if (hg_fabsCGFloat(position.y - p2.position.y) > tolerance.y) // clicked outside the horizontal line, cancel
        {
            return nil;
        }
        
        CGFloat offsetX = p2.position.x - position.x;
        
        p2.leftControlOffset = CGPointMake(-.25 * offsetX, 0.0);
        if (p2.hasRightControl)
        {
            // set offset with small length but keeping the other one intact, basically adding a control point.
            [p2 setRightControlPointPosition:p2.rightControlPosition];
        }
        
        HGCurvePoint *newCurvePoint = [HGCurvePoint pointWithPosition:CGPointMake(position.x, p2.position.y)
                                                   rightControlOffset:CGPointMake(.25 * offsetX, 0.0)];
        
        [self insertPoint:newCurvePoint atIndex:0];
        
        return newCurvePoint;
    }
    
    //
    // clicked on the line to the right of the last point.
    //
    p2 = self.points.lastObject;
    if (p2.position.x < position.x)
    {
        if (position.x >= 1.)
            return nil;
        
        p2 = self.points.lastObject;
        
        if (hg_fabsCGFloat(position.y - p2.position.y) > tolerance.y) // clicked outside the horizontal line
        {
            return nil;
        }
        
        CGFloat offsetX = position.x - p2.position.x;
        
        p2.rightControlOffset = CGPointMake(-.25 * offsetX, 0.0);
        if (p2.hasLeftControl)
        {
            // set offset with small length but keeping the other one intact, basically adding a control point.
            [p2 setLeftControlPointPosition:p2.leftControlPosition];
        }
        
        HGCurvePoint *newCurvePoint = [HGCurvePoint pointWithPosition:CGPointMake(position.x, p2.position.y)
                                                    leftControlOffset:CGPointMake(.25 * offsetX, 0.0)];
        
        [self addPoint:newCurvePoint];
        
        return newCurvePoint;
    }
    
    //
    // Inserting a point on a curve segment
    //
    NSInteger p2Index = [self.points indexOfObjectPassingTest:^BOOL(HGCurvePoint *point, NSUInteger idx, BOOL *stop) {
        if (point.position.x > position.x)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (p2Index == NSNotFound)
        return nil;
    
    p2 = [self.points objectAtIndex:p2Index];
    HGCurvePoint *p1 = self.points[p2Index - 1];
    HGBezierCurve bezierSegment = HGBezierCurveMake(
                                              p1.position,
                                              p1.rightControlPosition,
                                              p2.leftControlPosition,
                                              p2.position);

    // Find <t> for a point on the Bezier curve with given horizontal coordinate
    CGFloat roots[3];
    size_t rootCount = HGBezierCurveSolveX(position.x,
                                        bezierSegment,
                                        roots);
    
    if (rootCount == 0 || isnan(roots[0])) // unsolvable?
        return nil;
    
    CGFloat t = roots[0];
    
    // calculate the actual point on the curve in order to verify <y> coordinate
    CGPoint pt = HGBezierCurveInterpolatePoint(t, bezierSegment);
    CGFloat distance = HGCGPointLengthSquared(HGCGPointSubtract(position, pt));
    if (distance > HGCGPointLengthSquared(tolerance)) // clicked too far
        return nil;
    
    // within tolerance, ok to split!
    HGBezierCurve  *splitCurves;
    size_t curvesCount = HGBezierCurveSplit(t,
                                              bezierSegment,
                                              &splitCurves);
    
    if (curvesCount == 0)
        return nil;
    
    HGBezierCurve curve1 = splitCurves[0];
    HGBezierCurve curve2 = splitCurves[1];
    
    p1.rightControlOffset = HGCGPointSubtract(curve1.p2, p1.position);
    p2.leftControlOffset = HGCGPointSubtract(curve2.p3, p2.position);
    
    HGCurvePoint *newCurvePoint = [HGCurvePoint pointWithPosition:curve1.p4
                                                leftControlOffset:HGCGPointSubtract(curve1.p3, curve1.p4)
                                               rightControlOffset:HGCGPointSubtract(curve2.p2, curve2.p1)];
    
    [self insertPoint:newCurvePoint atIndex:p2Index];
    
    return newCurvePoint;
}

- (void)addPoint:(HGCurvePoint *)point
{
    NSMutableArray *points = [self mutableArrayValueForKey:@"points"];
    [points addObject:point];
}

- (void)insertPoint:(HGCurvePoint *)point atIndex:(NSUInteger)index
{
    NSMutableArray *points = [self mutableArrayValueForKey:@"points"];
    [points insertObject:point atIndex:index];
}

- (CGPoint)maxPoint
{
    __block CGPoint maxPoint = CGPointMake(0, 0);
    [self.points enumerateObjectsUsingBlock:^(HGCurvePoint *point, NSUInteger idx, BOOL *stop) {
        if (point.position.y > maxPoint.y)
            maxPoint = point.position;
    }];
    return maxPoint;
}

#pragma mark - Representing

- (CGPathRef)CGPathInRect:(HGRect)rect
{
    CGMutablePathRef curveBezierPath = CGPathCreateMutable();
    
    HGCurvePoint *point;
    CGPoint pointPosition, lastPointRightHandlePosition, pointLeftHandlePosition;
    
    point = self.points[0];
    pointPosition = HGCGPointAdd(rect.origin,
                               HGCGPointDenormalized(point.position, rect.size));
    
    if (point.hasRightControl)
    {
        lastPointRightHandlePosition = HGCGPointAdd(rect.origin,
                                                  HGCGPointDenormalized(point.rightControlPosition, rect.size));
    }
    else
    {
        lastPointRightHandlePosition = pointPosition;
    }
    
    CGPathMoveToPoint(curveBezierPath, NULL, CGRectGetMinX(rect), pointPosition.y);
    if (point.position.x > CGRectGetMinX(rect))
        CGPathAddLineToPoint(curveBezierPath, NULL, pointPosition.x, pointPosition.y);
    
    for (NSInteger i = 1; i<self.points.count; i++)
    {
        point = self.points[i];
        pointPosition = HGCGPointAdd(rect.origin,
                                   HGCGPointDenormalized(point.position, rect.size));
        
        if (point.hasLeftControl)
        {
            pointLeftHandlePosition = HGCGPointAdd(rect.origin,
                                                 HGCGPointDenormalized(point.leftControlPosition, rect.size));
        }
        else
        {
            pointLeftHandlePosition = pointPosition;
        }
        
        CGPathAddCurveToPoint(curveBezierPath, NULL,
                              lastPointRightHandlePosition.x, lastPointRightHandlePosition.y,
                              pointLeftHandlePosition.x, pointLeftHandlePosition.y,
                              pointPosition.x, pointPosition.y);
        
        if (point.hasRightControl)
        {
            lastPointRightHandlePosition = HGCGPointAdd(rect.origin,
                                                      HGCGPointDenormalized(point.rightControlPosition, rect.size));
        }
        else
        {
            lastPointRightHandlePosition = pointPosition;
        }
    }
    
    // extend last horizontal line
    if (pointPosition.x < CGRectGetMaxX(rect))
        CGPathAddLineToPoint(curveBezierPath, NULL, rect.origin.x + rect.size.width, pointPosition.y);
    
    return curveBezierPath;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<HGCurve %p> %.02f %@", self, self.multiplier, [self.points componentsJoinedByString:@", "]];
}

- (HGLookupTableRef)lookupTableWithSize:(NSUInteger)size
{
    HGAssert(size >= 2, @"LUT size must be at least 2.");

    if (self.points.count == 0)
    {
        NSLog(@"HGCurve is empty, returning a nil LUT");
        return nil;
    }
    
    HGCurvePoint *point1, *point2;
    if (self.points.count == 1)
    {
        point1 = self.points.lastObject;
        
        HGFloat positions[2] = {point1.position.y, point1.position.y};
        
        return HGLookupTableMakeWithFloat(positions, 2, self.mirroredRange ? - self.multiplier : 0.0, self.multiplier);
    }
    
    NSMutableArray *actualPoints = self.points.mutableCopy;
    // actual points may include extra points for cases
    // when the first one is at t>0 and/or the last one is at t<1
    point1 = actualPoints.firstObject;
    if (point1.position.x > 0.0)
    {
        point1 = point1.copy;
        point1.position = CGPointMake(0.0, point1.position.y);
        [actualPoints insertObject:point1 atIndex:0];
    }
    
    point1 = actualPoints.lastObject;
    if (point1.position.x < 1.0)
    {
        point1 = point1.copy;
        point1.position = CGPointMake(1.0, point1.position.y);
        [actualPoints insertObject:point1 atIndex:actualPoints.count];
    }

    HGFloat *values = calloc(size, sizeof(HGFloat));

    NSUInteger pointIndex = 0;
    HGBezierCurve curve;
    
    CGFloat roots[3];
    size_t rootCount = 0;
    
    CGFloat newValue;
    
    // have to use CGFLOAT_EPSILON because in some cases (e.g. size = 16) lutX would climb close enough to 1.0
    // to trick the program into running an extra loop cycle, which would cause writing outside the allocated array on the heap
    CGFloat lutX = 0., stepX = 1./(size - 1);
    for (NSUInteger i = 0; i < size - 1; lutX += stepX, i++)
    {
        if (point2 == nil || lutX > point2.position.x)
        {
            point1 = actualPoints[pointIndex];
            point2 = actualPoints[pointIndex+1];
            curve = HGBezierCurveMake(point1.position,
                                      point1.rightControlPosition,
                                      point2.leftControlPosition,
                                      point2.position);
            pointIndex += 1;
        }

        if (hg_fabsCGFloat(lutX - point1.position.x) < HGCGFLOAT_EPSILON)
        {
            newValue = point1.position.y;
        }
        else if (hg_fabsCGFloat(lutX - point2.position.x) < HGCGFLOAT_EPSILON)
        {
            newValue = point2.position.y;
        }
        else
        {
            // Find <t> for a point on the Bezier curve with given horizontal coordinate
            rootCount = HGBezierCurveSolveX(lutX,
                                         curve,
                                         roots);
            
            if (rootCount == 0) // unsolvable?
            {
                newValue = NAN;
            }
            else if (isnan(roots[0]))
            {
                newValue = NAN;
            }
            else
            {
                CGFloat t = roots[0];
                // calculate the actual point on the curve in order to verify <y> coordinate
                CGPoint pt = HGBezierCurveInterpolatePoint(t, curve);
                newValue = pt.y;
            }
        }
        values[i] = newValue;
    }
    // last point
    point1 = actualPoints.lastObject;
    values[size - 1] = point1.position.y;
    
    HGLookupTableRef lut = HGLookupTableMakeWithFloat(values, size, self.mirroredRange ? - self.multiplier : 0.0, self.multiplier);

    if (values)
        free(values);
    
    return lut;
}

#pragma mark - Curve serialization

+ (instancetype)curveWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    HGAssert(dictionary, @"HGCurve: nil dictionary");
    HGAssert(dictionary[@"points"], @"HGCurve: missing <points>");

    self = [super init];
    if (self) {
        NSNumber *multiplier = dictionary[@"multiplier"];
        if (multiplier)
        {
            _multiplier = [multiplier hg_CGFloatValue];
        }
        
        NSArray *dictionaryPoints = dictionary[@"points"];
        NSMutableArray *points = NSMutableArray.array;
        for (NSInteger i = 0; i<dictionaryPoints.count; i++)
        {
            [points addObject:[HGCurvePoint pointWithDictionary:dictionaryPoints[i]]];
        }
        _points = points;
    }
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableArray *array = NSMutableArray.array;
    for (NSInteger i = 0; i < self.points.count; i++)
    {
        HGCurvePoint *point = self.points[i];
        [array addObject:point.dictionary];
    }
    return @{@"valueClass": @"HGCurve", @"multiplier": @(self.multiplier), @"points": array};
}

@end
