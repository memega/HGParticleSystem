//
//  HGGradient.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 03/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"
#import "HGLookupTable.h"

@interface HGGradient : NSObject <NSCopying, NSMutableCopying>

+ (HGColor *)defaultColor;
+ (NSNumber *)defaultOpacity;

// serialization
+ (instancetype)gradientWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@property (nonatomic, readonly) NSArray *colors; // NSColor
@property (nonatomic, readonly) NSArray *colorLocations; // NSNumber, 0..1
@property (nonatomic, readonly) NSArray *opacities; // NSNumber, 0..1
@property (nonatomic, readonly) NSArray *opacityLocations; // NSNumber, 0..1

+ (HGGradient *)gradientWithColor:(HGColor *)color;

- (BOOL)isEqualToGradient:(HGGradient *)gradient;

- (HGColor *)colorAtLocation:(NSNumber *)location;
- (NSNumber *)opacityAtLocation:(NSNumber *)location;

- (NSArray *)flatHGColorsWithAlpha; // HGColor
- (NSArray *)flatCGColorsWithAlpha; // CGColor
- (NSArray *)flatLocations; // NSNumber, 0..1

- (CGGradientRef)CGGradient;

/// size is number of approximation points, cannot be less than 2
- (HGLookupTableRef)lookupTableWithSize:(NSUInteger)size;

@end

@interface HGGradientMutable : HGGradient

@property (nonatomic) NSArray *colors;
@property (nonatomic) NSArray *colorLocations;
@property (nonatomic) NSArray *opacities;
@property (nonatomic) NSArray *opacityLocations;

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(HGColor *)color;
- (void)replaceColorLocationAtIndex:(NSUInteger)index withLocation:(NSNumber *)location;
- (void)replaceOpacityAtIndex:(NSUInteger)index withOpacity:(NSNumber *)opacity;
- (void)replaceOpacityLocationAtIndex:(NSUInteger)index withLocation:(NSNumber *)location;

- (void)removeColorAtIndex:(NSUInteger)index;
- (void)removeOpacityAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfOpacityLocation:(NSNumber *)location;
- (NSUInteger)indexOfColorLocation:(NSNumber *)location;

- (void)insertColor:(HGColor *)color withLocation:(NSNumber *)location atIndex:(NSUInteger)index;
- (void)insertOpacity:(NSNumber *)opacity withLocation:(NSNumber *)location atIndex:(NSUInteger)index;

- (void)addColor:(HGColor *)color withLocation:(NSNumber *)location;
- (void)addOpacity:(NSNumber *)opacity withLocation:(NSNumber *)location;

@end