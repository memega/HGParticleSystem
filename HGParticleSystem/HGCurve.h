//
//  HGCurve.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 02/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGLookupTable.h"

#pragma mark - Curve point

@interface HGCurvePoint : NSObject <NSCopying>

/// own space is normalized!
@property (nonatomic) CGPoint position;
@property (nonatomic) CGPoint leftControlOffset;
@property (nonatomic) CGPoint rightControlOffset;

//
+ (instancetype)pointWithPosition:(CGPoint)position;
+ (instancetype)pointWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl;
+ (instancetype)pointWithPosition:(CGPoint)position rightControlOffset:(CGPoint)rightControl;
+ (instancetype)pointWithPosition:(CGPoint)position leftControlOffset:(CGPoint)leftControl rightControlOffset:(CGPoint)rightControl;

/// accepts normalized values; updates right control position!
- (void)setLeftControlPointPosition:(CGPoint)position;
/// absolute value
- (CGPoint)leftControlPosition;
/// accepts normalized values; updates left control position!
- (void)setRightControlPointPosition:(CGPoint)position;
/// absolute value
- (CGPoint)rightControlPosition;

- (BOOL)hasLeftControl;
- (BOOL)hasRightControl;

// serialization
- (NSDictionary *)dictionary;
+ (instancetype)pointWithDictionary:(NSDictionary *)dictionary;

@end

#pragma mark - Curve

/// Note: horizontal values are always in range [0.0 .. 1.0]
@interface HGCurve : NSObject <NSCopying>

@property (nonatomic, readonly) NSArray *points; // HGCurvePoint

///
@property (nonatomic, readonly) CGFloat multiplier;
/// When set to YES, vertical values are in range [-1.0 .. 1.0]
/// When set to NO. vertical values are in range [0.0 .. 1.0]
@property (nonatomic, readonly) BOOL mirroredRange;

/// Convenience method
/// Automatically normalizes the point and sets an appropriate vertical range
/// Point x values are clamped into range [0.0 .. 1.0]
+ (instancetype)curveByNormalizingPoint:(CGPoint)point;

/// Convenience method
/// Accepts normalized values only
+ (instancetype)curveWithPoints:(NSArray *)points multiplier:(CGFloat)multiplier;

// mutability
- (HGCurve *)curveWithMultiplier:(CGFloat)multiplier mirrored:(BOOL)mirrored;

/// Finds bezier segment, solves it and attempts to insert a new point if position provided is within <tolerance> radius
- (HGCurvePoint *)insertPointAtPosition:(CGPoint)position tolerance:(CGPoint)tolerance;
- (HGCurvePoint *)insertPointAtPosition:(CGPoint)position;

- (void)removePoint:(HGCurvePoint *)point;

- (CGPathRef)CGPathInRect:(HGRect)rect;

- (CGPoint)maxPoint;

/// size is number of approximation points, cannot be less than 2
- (HGLookupTableRef)lookupTableWithSize:(NSUInteger)size;

// serialization
- (NSDictionary *)dictionary;
+ (instancetype)curveWithDictionary:(NSDictionary *)dictionary;

@end
