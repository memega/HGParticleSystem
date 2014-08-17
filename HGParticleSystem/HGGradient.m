//
//  HGGradient.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 03/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGGradient.h"

#import "HGAssert.h"
#import "HGLookupTable.h"

#import "_HGGradientItemList.h"

#import "CGFloatAdditions.h"
#import "HGColor+HGGradientAdditions.h"
#import "HGColor+Serialization.h"

#pragma mark - Array operations

NSArray *MapArray(NSArray *array, id (^block)(id))
{
    NSCParameterAssert(block);
    
    if (array == nil) return nil;
    
    NSMutableArray *result = NSMutableArray.array;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id transformedObject = block(obj);
        
        if (transformedObject) {
            [result addObject:transformedObject];
        }
    }];
    
    return result;
}

#pragma mark - Gradient

@interface HGGradient ()
{
    @protected
    NSArray *_colors;
    NSArray *_colorLocations;
    NSArray *_opacities;
    NSArray *_opacityLocations;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithColor:(HGColor *)color;

@property (nonatomic) _HGGradientItemList *opacitiesInternal;
@property (nonatomic) _HGGradientItemList *colorsInternal;

- (void)updateColorsInternal;
- (void)updateOpacitiesInternal;

@end

@implementation HGGradient

@synthesize colors=_colors,colorLocations=_colorLocations,opacities=_opacities,opacityLocations=_opacityLocations;

+ (HGColor *)defaultColor
{
    return [HGColor colorWithRed:1 green:1 blue:1 alpha:1];
}

+ (NSNumber *)defaultOpacity
{
    return @(1.);
}

#pragma mark - Initialization

+ (HGGradient *)gradientWithColor:(HGColor *)color
{
    return [[[self class] alloc] initWithColor:color];
}

- (instancetype)init
{
    return [self initWithColor:[[self class] defaultColor]];
}

// designated
- (instancetype)initWithColor:(HGColor *)color
{
    self = [super init];
    if (self) {
        HGColor *internalColor = color;
        _colors = @[internalColor, internalColor];
        _colorLocations = @[@(0.), @(1.)];
        _opacities = @[@([internalColor hg_alphaComponent]), @([internalColor hg_alphaComponent])];
        _opacityLocations = @[@(0.), @(1.)];
        
        [self updateColorsInternal];
        [self updateOpacitiesInternal];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self.class != [object class])
        return NO;
    
    HGGradient *other = (HGGradient *)object;
    
    return [self isEqualToGradient:other];
}

- (BOOL)isEqualToGradient:(HGGradient *)gradient
{
    if (![self.colors isEqualToArray:gradient.colors])
        return NO;
    
    if (![self.colorLocations isEqualToArray:gradient.colorLocations])
        return NO;
    
    if (![self.opacities isEqualToArray:gradient.opacities])
        return NO;
    
    if (![self.opacityLocations isEqualToArray:gradient.opacityLocations])
        return NO;
    
    return YES;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    HGGradientMutable *mutable = [[HGGradientMutable allocWithZone:zone] init];
    mutable.colors = MapArray(self.colors, ^id(id obj) { return [obj copy]; });
    mutable.colorLocations = MapArray(self.colorLocations, ^id(id obj) { return [obj copy]; });
    mutable.opacities = MapArray(self.opacities, ^id(id obj) { return [obj copy]; });
    mutable.opacityLocations = MapArray(self.opacityLocations, ^id(id obj) { return [obj copy]; });
    return mutable;
}

- (id)copyWithZone:(NSZone *)zone
{
    HGGradient *copy = [[[self class] allocWithZone:zone] init];
    copy->_colors = MapArray(self.colors, ^id(id obj) { return [obj copy]; });
    copy->_colorLocations = MapArray(self.colorLocations, ^id(id obj) { return [obj copy]; });
    copy->_opacities = MapArray(self.opacities, ^id(id obj) { return [obj copy]; });
    copy->_opacityLocations = MapArray(self.opacityLocations, ^id(id obj) { return [obj copy]; });
    [copy updateColorsInternal];
    [copy updateOpacitiesInternal];
    return copy;
}

- (NSString *)description
{
    NSString *(^prettyPrintArrayAtLocations)(NSArray *, NSArray *) = ^NSString *(NSArray *array, NSArray *locations)
    {
        NSMutableString *result = @"[".mutableCopy;
        for (NSUInteger i = 0; i<array.count; i++)
        {
            if (i > 0) {
                [result appendString:@", "];
            }
            id obj = array[i];
            if ([obj isKindOfClass:HGColor.class])
            {
                HGColor *color = (HGColor *)obj;
                [result appendString:[color hg_hexDescriptionWithoutAlpha]];
            }
            else if ([obj isKindOfClass:NSNumber.class])
            {
                [result appendFormat:@"%.02f", [obj doubleValue]];
            }
            
            id location = locations[i];
            [result appendFormat:@"(%.02f)", [location doubleValue]];
        };
        [result appendString:@"]"];
        return result;
    };
    NSString *className = NSStringFromClass(self.class);
    if (className.length < 18) className = [className stringByPaddingToLength:18 withString:@" " startingAtIndex:0];
    return [NSString stringWithFormat:@"<%@ %p> colors %@, opacities %@",
            className, self,
            prettyPrintArrayAtLocations(self.colors, self.colorLocations),
            prettyPrintArrayAtLocations(self.opacities, self.opacityLocations)
            ];
}

#pragma mark - Internal

- (void)updateColorsInternal
{
    if(self.colors.count == self.colorLocations.count)
        self.colorsInternal = [_HGGradientItemList listWithLocations:self.colorLocations
                                                              values:self.colors
                                                        defaultValue:[[self class] defaultColor]];
    else
        self.colorsInternal = nil;
}

- (void)updateOpacitiesInternal
{
    if(self.opacities.count == self.opacityLocations.count)
        self.opacitiesInternal = [_HGGradientItemList listWithLocations:self.opacityLocations
                                                                 values:self.opacities
                                                           defaultValue:[[self class] defaultOpacity]];
    else
        self.opacitiesInternal = nil;
}

- (HGColor *)colorAtLocation:(NSNumber *)location
{
    return [self.colorsInternal valueForLocation:location];
}

- (NSNumber *)opacityAtLocation:(NSNumber *)location
{
    return [self.opacitiesInternal valueForLocation:location];
}

- (NSArray *)flatHGColorsWithAlpha
{
    return MapArray(self.flatLocations, ^id(NSNumber *location) {
        NSNumber *opacity = [self opacityAtLocation:location];
        HGColor *color = [self colorAtLocation:location];
        // both opacity and color are known
#if CGFLOAT_IS_DOUBLE
        return [color colorWithAlphaComponent:[opacity doubleValue]];
#else
        return [color colorWithAlphaComponent:[opacity floatValue]];
#endif
    });
}

- (NSArray *)flatCGColorsWithAlpha
{
    return MapArray(self.flatHGColorsWithAlpha, ^id(HGColor *color) {
        return (__bridge id)color.CGColor;
    });
}

- (NSArray *)flatLocations
{
    NSMutableArray *locations = self.colorsInternal.locations.mutableCopy;
    [locations removeObjectsInArray:self.opacitiesInternal.locations];
    [locations addObjectsFromArray:self.opacitiesInternal.locations];
    return [locations sortedArrayUsingComparator:^NSComparisonResult(NSNumber *location1, NSNumber *location2) {
        return [location1 compare:location2];
    }];
}

- (CGGradientRef)CGGradient
{
    NSArray *flatLocations = self.flatLocations;
    CGFloat *locations = calloc(flatLocations.count, sizeof(CGFloat));
    
    __block NSInteger index = 0;
    [flatLocations enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        *(locations + index) = [number hg_CGFloatValue];
        index ++;
    }];
    return CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)self.flatCGColorsWithAlpha, locations);
}

- (HGLookupTableRef)lookupTableWithSize:(NSUInteger)size
{
    HGAssert(size > 2, @"LUT size must be at least 2.");

    NSArray *flatLocations = self.flatLocations;

    if (flatLocations.count == 0)
    {
        NSLog(@"HGGradient is empty, returning a nil LUT");
        return nil;
    }

    HGColor *color;
    
    NSArray *flatHGColorsWithAlpha = self.flatHGColorsWithAlpha;
    if (flatLocations.count == 1)
    {
        color = flatHGColorsWithAlpha.lastObject;
        
        GLKVector4 vectors[2] = {HGGLKVector4MakeWithColor(color), HGGLKVector4MakeWithColor(color)};
        return HGLookupTableMakeWithGLKVector4(vectors, 2);
    }
    
    GLKVector4 *values = calloc(size, sizeof(GLKVector4));
    
    CGFloat lutX = 0., stepX = 1./(size - 1);
    for (NSUInteger i = 0; i < size - 1; lutX += stepX, i++)
    {
        values[i] = HGGLKVector4MakeWithColor([[self colorAtLocation:@(lutX)] colorWithAlphaComponent:[[self opacityAtLocation:@(lutX)] hg_CGFloatValue]]);
    }
    // last point
    values[size - 1] = HGGLKVector4MakeWithColor([[self colorAtLocation:@(1.0)] colorWithAlphaComponent:[[self opacityAtLocation:@(1.0)] hg_CGFloatValue]]);
    
    HGLookupTableRef lut = HGLookupTableMakeWithGLKVector4(values, size);

    if (values)
        free(values);
    
    return lut;
}

#pragma mark - Serialization

+ (instancetype)gradientWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

//
// FIXME: value validation!
//
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    HGAssert(dictionary, @"HGGradient: nil dictionary");
    HGAssert(dictionary[@"colors"], @"HGGradient: missing <colors>");
    HGAssert(dictionary[@"colorLocations"], @"HGGradient: missing <colorLocations>");
    
    self = [super init];
    if (self)
    {
        _opacities = dictionary[@"opacities"];
        _opacityLocations = dictionary[@"opacityLocations"];
        HGAssert(_opacities.count == _opacityLocations.count, @"HGGradient: mismatching counts for opacities and opacityLocations");
        
        NSArray *serializedColors = dictionary[@"colors"];
        _colors = MapArray(serializedColors, ^id(NSDictionary *colorDictionary) {
            return [HGColor hg_colorWithDictionary:colorDictionary];
        });
        _colorLocations = dictionary[@"colorLocations"];
        HGAssert(_colors.count == _colorLocations.count, @"HGGradient: mismatching counts for colors and colorLocations");

        [self updateColorsInternal];
        [self updateOpacitiesInternal];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"opacities"] = self.opacities;
    dictionary[@"opacityLocations"] = self.opacityLocations;

    NSMutableArray *serializedColors = NSMutableArray.array;
    [self.colors enumerateObjectsUsingBlock:^(HGColor *color, NSUInteger idx, BOOL *stop) {
        [serializedColors addObject:[color hg_dictionary]];
    }];
    dictionary[@"colors"] = serializedColors;
    dictionary[@"colorLocations"] = self.colorLocations;
    dictionary[@"valueClass"] = @"HGGradient";
    
    return dictionary;
}

@end

@implementation HGGradientMutable

- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    
    [self updateColorsInternal];
}

- (void)setColorLocations:(NSArray *)colorLocations
{
    _colorLocations = colorLocations;

    [self updateColorsInternal];
}

- (void)setOpacities:(NSArray *)opacities
{
    _opacities = opacities;
    
    [self updateOpacitiesInternal];
}

- (void)setOpacityLocations:(NSArray *)opacityLocations
{
    _opacityLocations = opacityLocations;

    [self updateOpacitiesInternal];
}

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(HGColor *)color
{
    NSMutableArray *colors = self.colors.mutableCopy;
    [colors replaceObjectAtIndex:index withObject:color];
    self.colors = colors;
    
    // NOTE: internal values are updated in setters!
}

- (void)replaceOpacityAtIndex:(NSUInteger)index withOpacity:(NSNumber *)opacity
{
    NSMutableArray *opacities = self.opacities.mutableCopy;
    [opacities replaceObjectAtIndex:index withObject:opacity];
    self.opacities = opacities;
    
    // NOTE: internal values are updated in setters!
}

- (void)replaceColorLocationAtIndex:(NSUInteger)index withLocation:(NSNumber *)location
{
    NSMutableArray *colorLocations = self.colorLocations.mutableCopy;
    [colorLocations replaceObjectAtIndex:index withObject:location];
    self.colorLocations = colorLocations;
    
//    NSArray *sortedColorLocations = ASTSort(colorLocations);
//    NSMutableArray *colors = self.colors.mutableCopy;
//    NSMutableArray *sortedColors = NSMutableArray.array;
//    ASTEach(sortedColorLocations, ^(NSNumber *colorLocation) {
//        NSUInteger index = ASTIndexOf(colorLocations, colorLocation);
//        [sortedColors addObject:colors[index]];
//    });
//    
//    self.colorLocations = sortedColorLocations;
//    self.colors = sortedColors;
    
    // NOTE: internal values are updated in setters!
}

- (void)replaceOpacityLocationAtIndex:(NSUInteger)index withLocation:(NSNumber *)location
{
    NSMutableArray *opacityLocations = self.opacityLocations.mutableCopy;
    [opacityLocations replaceObjectAtIndex:index withObject:location];
    self.opacityLocations = opacityLocations;
    
//    NSArray *sortedOpacityLocations = ASTSort(opacityLocations);
//    NSMutableArray *opacities = self.opacities.mutableCopy;
//    NSMutableArray *sortedOpacities = NSMutableArray.array;
//    ASTEach(sortedOpacityLocations, ^(NSNumber *opacityLocation) {
//        NSUInteger index = ASTIndexOf(opacityLocations, opacityLocation);
//        [sortedOpacities addObject:opacities[index]];
//    });
//    
//    self.opacityLocations = sortedOpacityLocations;
//    self.opacities = sortedOpacities;

    // NOTE: internal values are updated in setters!
}

- (void)removeColorAtIndex:(NSUInteger)index
{
    HGAssert(index < self.colors.count, @"%s index %tu is out of bounds.", __PRETTY_FUNCTION__, index);
    
    NSMutableArray *colors = self.colors.mutableCopy;
    [colors removeObjectAtIndex:index];
    self.colors = colors;
    
    NSMutableArray *colorLocations = self.colorLocations.mutableCopy;
    [colorLocations removeObjectAtIndex:index];
    self.colorLocations = colorLocations;
    
    // NOTE: internal values are updated in setters!
}

- (void)removeOpacityAtIndex:(NSUInteger)index
{
    HGAssert(index < self.opacities.count, @"%s index %tu is out of bounds.", __PRETTY_FUNCTION__, index);
    
    NSMutableArray *opacities = self.opacities.mutableCopy;
    [opacities removeObjectAtIndex:index];
    self.opacities = opacities;
    
    NSMutableArray *opacityLocations = self.opacityLocations.mutableCopy;
    [opacityLocations removeObjectAtIndex:index];
    self.opacityLocations = opacityLocations;
    
    // NOTE: internal values are updated in setters!
}

- (NSUInteger)indexOfOpacityLocation:(NSNumber *)location
{
    return [self.opacityLocations indexOfObject:location];
}

- (NSUInteger)indexOfColorLocation:(NSNumber *)location
{
    return [self.colorLocations indexOfObject:location];
}

- (void)insertColor:(HGColor *)color withLocation:(NSNumber *)location atIndex:(NSUInteger)index
{
    // insert new values
    NSMutableArray *colors = self.colors.mutableCopy;
    [colors insertObject:color atIndex:index];
    self.colors = colors;
    
    NSMutableArray *colorLocations = self.colorLocations.mutableCopy;
    [colorLocations insertObject:location atIndex:index];
    self.colorLocations = colorLocations;
    
    // NOTE: internal values are updated in setters!
}

- (void)insertOpacity:(NSNumber *)opacity withLocation:(NSNumber *)location atIndex:(NSUInteger)index
{
    // insert new values
    NSMutableArray *opacities = self.opacities.mutableCopy;
    [opacities insertObject:opacity atIndex:index];
    self.opacities = opacities;
    
    NSMutableArray *opacityLocations = self.opacityLocations.mutableCopy;
    [opacityLocations insertObject:location atIndex:index];
    self.opacityLocations = opacityLocations;
    
    // NOTE: internal values are updated in setters!
}

- (void)addColor:(HGColor *)color withLocation:(NSNumber *)location
{
    // insert new values
    NSMutableArray *colors = self.colors.mutableCopy;
    [colors addObject:color];
    self.colors = colors;
    
    NSMutableArray *colorLocations = self.colorLocations.mutableCopy;
    [colorLocations addObject:location];
    self.colorLocations = colorLocations;
    
    // NOTE: internal values are updated in setters!
}

- (void)addOpacity:(NSNumber *)opacity withLocation:(NSNumber *)location
{
    // insert new values
    NSMutableArray *opacities = self.opacities.mutableCopy;
    [opacities addObject:opacity];
    self.opacities = opacities;
    
    NSMutableArray *opacityLocations = self.opacityLocations.mutableCopy;
    [opacityLocations addObject:location];
    self.opacityLocations = opacityLocations;
    
    // NOTE: internal values are updated in setters!
}

@end
