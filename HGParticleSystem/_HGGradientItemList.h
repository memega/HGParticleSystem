//
//  _HGGradientItemList.h
//  HGParticleEditor
//
//  Created by Yuriy Panfyorov on 04/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _HGGradientItemList : NSObject

@property (nonatomic) NSArray *locations;
@property (nonatomic) NSArray *values;

@property (nonatomic) NSArray *items;

+ (instancetype)listWithLocations:(NSArray *)locations values:(NSArray *)values defaultValue:(id)defaultValue;

- (id)valueForLocation:(NSNumber *)location;

@end