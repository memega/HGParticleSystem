//
//  NSColor+Serialization.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 16/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGTypes.h"

@interface HGColor (Serialization)

+ (instancetype)hg_colorWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)hg_dictionary;

@end
