//
//  _HGGradientItemList.m
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "_HGGradientItemList.h"

#import "_HGGradientItem.h"

#import "HGAssert.h"
#import "CGFloatAdditions.h"

@interface _HGGradientItemList ()
{
    NSMutableArray *_values;
    NSMutableArray *_locations;
}

@property (nonatomic) id defaultValue;

@end

#pragma mark - _HGGradientItemList

@implementation _HGGradientItemList

@synthesize values=_values, locations=_locations;

+ (instancetype)listWithLocations:(NSArray *)locations values:(NSArray *)values defaultValue:(id)defaultValue
{
    return [[self alloc] initWithLocations:locations values:values defaultValue:defaultValue];
}

- (instancetype)initWithLocations:(NSArray *)locations values:(NSArray *)values defaultValue:(id)defaultValue
{
    HGAssert([defaultValue conformsToProtocol:@protocol(_HGGradientBlendedValue)],
             @"%s default value must conform to _HGGradientBlendedValue protocol.", __PRETTY_FUNCTION__);
    HGAssert([defaultValue conformsToProtocol:@protocol(NSCopying)],
             @"%s default value must conform to NSCopying protocol.", __PRETTY_FUNCTION__);
    self = [super init];
    if (self) {
        _locations = locations.mutableCopy;
        _values = values.mutableCopy;
        _defaultValue = [defaultValue copy];
        
        [self updateItems];
    }
    return self;
}

#pragma mark - Properties

- (void)setValues:(NSArray *)values
{
    _values = values.mutableCopy;
    
    [self updateItems];
}

- (void)setLocations:(NSArray *)locations
{
    _locations = locations.mutableCopy;
    
    [self updateItems];
}

#pragma mark - Derived values

- (void)updateItems
{
    if (self.locations.count != self.values.count)
    {
        self.items = nil;
        return;
    }
    
    NSMutableArray *items = NSMutableArray.array;
    for (NSInteger i = 0; i < self.locations.count; i++)
    {
        _HGGradientItem *item = [_HGGradientItem itemWithLocation:[self.locations[i] hg_CGFloatValue] value:self.values[i]];
        [items addObject:item];
    }
    items = [items sortedArrayUsingComparator:^NSComparisonResult(_HGGradientItem *item1, _HGGradientItem *item2) {
        return [item1.location compare:item2.location];
    }].mutableCopy;
    
    if (items.count > 0)
    {
        _HGGradientItem *firstItem = items.firstObject;
        _HGGradientItem *lastItem = items.lastObject;
        
        if ( ![firstItem.location isEqualToNumber:@(0.)])
        {
            firstItem = firstItem.copy;
            firstItem.location = @(0.);
            [items insertObject:firstItem atIndex:0];
            
            [_values insertObject:firstItem.value atIndex:0];
            [_locations insertObject:@(0.) atIndex:0];
        }
        
        if ( ![lastItem.location isEqualToNumber:@(1.)])
        {
            lastItem = lastItem.copy;
            lastItem.location = @(1.);
            [items addObject:lastItem];

            [_values addObject:lastItem.value];
            [_locations addObject:@(1.)];
        }
        
        self.items = items;
    }
    else
    {
        _locations = @[@(0.), @(1.)].mutableCopy;
        _values = @[[self.defaultValue copy], [self.defaultValue copy]].mutableCopy;
        self.items = @[
                  [_HGGradientItem itemWithLocation:0. value:[self.defaultValue copy]],
                  [_HGGradientItem itemWithLocation:1. value:[self.defaultValue copy]]
                  ].mutableCopy;
    }
}

#pragma mark - Helpers

- (_HGGradientItem *)nextItemForLocation:(NSNumber *)location
{
    NSInteger index = [self.items indexOfObjectPassingTest:^BOOL(_HGGradientItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.location hg_CGFloatValue] > [location hg_CGFloatValue])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index == NSNotFound) return nil;
    
    return self.items[index];
}

- (_HGGradientItem *)previousItemForLocation:(NSNumber *)location
{
    NSUInteger index = [self.items indexOfObjectWithOptions:NSEnumerationReverse
                                                passingTest:^BOOL(_HGGradientItem *item, NSUInteger idx, BOOL *stop) {
                                                    if ([item.location hg_CGFloatValue] < [location hg_CGFloatValue])
                                                    {
                                                        *stop = YES;
                                                        return YES;
                                                    }
                                                    
                                                    return NO;
                                                }];
    
    if (index == NSNotFound)
        return nil;
    
    return self.items[index];
}

- (id)valueForLocation:(NSNumber *)location
{
    CGFloat locationCGFloat = [location hg_CGFloatValue];
    HGAssert(locationCGFloat >= 0. && locationCGFloat <= 1., @"Location value %f must be within range 0..1", [location hg_CGFloatValue]);
    
    if (self.items.count == 0) return nil;
    
    // check if there is an exact location match
    NSInteger index = [self.items indexOfObjectPassingTest:^BOOL(_HGGradientItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.location isEqualToNumber:location])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound)
    {
        _HGGradientItem *item = self.items[index];
        if (item)
            return item.value;
    }
    
    _HGGradientItem *previousItem = [self previousItemForLocation:location];
    _HGGradientItem *nextItem = [self nextItemForLocation:location];
    
    CGFloat previousLocation = [previousItem.location hg_CGFloatValue];
    CGFloat nextLocation = [nextItem.location hg_CGFloatValue];
    
    CGFloat fraction = (locationCGFloat - previousLocation) / (nextLocation - previousLocation);
    
    return [previousItem.value blendedValueWithFraction:fraction ofValue:nextItem.value];
}

@end