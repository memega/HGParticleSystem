//
//  HGParticleSystemProperty.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 09/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGParticleSystemProperty.h"

// Data objects
#import "HGParticleSystemKeys.h"
#import "HGLookupTable.h"

// Helpers
#import "HGAssert.h"
//#import "HGColor+Serialization.h"

#ifndef HG_PROPERTY_CURVE_LUT_PRECISION
#define HG_PROPERTY_CURVE_LUT_PRECISION 32
#endif

#ifndef HG_PROPERTY_GRADIENT_LUT_PRECISION
#define HG_PROPERTY_GRADIENT_LUT_PRECISION 32
#endif

#pragma mark - Helpers

static HGColor *HGColorMakeWithDictionary(NSDictionary *dictionary)
{
    HGAssert(dictionary, @"HGColorMakeWithDictionary: nil dictionary");
    HGAssert(dictionary[@"redComponent"], @"HGColorMakeWithDictionary: missing redComponent");
    HGAssert(dictionary[@"greenComponent"], @"HGColorMakeWithDictionary: missing greenComponent");
    HGAssert(dictionary[@"blueComponent"], @"HGColorMakeWithDictionary: missing blueComponent");
    HGAssert(dictionary[@"alphaComponent"], @"HGColorMakeWithDictionary: missing alphaComponent");
    
    CGFloat redComponent, greenComponent, blueComponent, alphaComponent;

#if CGFLOAT_IS_DOUBLE
    redComponent = [dictionary[@"redComponent"] doubleValue];
    greenComponent = [dictionary[@"greenComponent"] doubleValue];
    blueComponent = [dictionary[@"blueComponent"] doubleValue];
    alphaComponent = [dictionary[@"alphaComponent"] doubleValue];
#else
    redComponent = [dictionary[@"redComponent"] floatValue];
    greenComponent = [dictionary[@"greenComponent"] floatValue];
    blueComponent = [dictionary[@"blueComponent"] floatValue];
    alphaComponent = [dictionary[@"alphaComponent"] floatValue];
#endif
    return [HGColor colorWithRed:redComponent
                           green:greenComponent
                            blue:blueComponent
                           alpha:alphaComponent];
}

static HGParticleSystemPropertyOption HGParticleSystemPropertyOptionFromString (NSString *string)
{
    static NSDictionary *propertiesDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertiesDictionary = @{
                                 HGPropertyValueOptionConstant: @(HGParticleSystemPropertyOptionConstant),
                                 HGPropertyValueOptionCurve: @(HGParticleSystemPropertyOptionCurve),
                                 HGPropertyValueOptionRandomConstants: @(HGParticleSystemPropertyOptionRandomConstants),
//                                 HGPropertyValueOptionRandomCurve: @(HGParticleSystemPropertyOptionRandomCurve),
                                 HGPropertyValueOptionColor: @(HGParticleSystemPropertyOptionColor),
                                 HGPropertyValueOptionColorRandomRGB: @(HGParticleSystemPropertyOptionColorRandomRGB),
                                 HGPropertyValueOptionColorRandomHSV: @(HGParticleSystemPropertyOptionColorRandomHSV),
                                 HGPropertyValueOptionGradient: @(HGParticleSystemPropertyOptionGradient),
                                 HGPropertyValueOptionRandomColors: @(HGParticleSystemPropertyOptionRandomColors),
//                                 HGPropertyValueOptionRandomGradients: @(HGParticleSystemPropertyOptionRandomGradients),
                                 };
    });
    return [propertiesDictionary[string] integerValue];
}

#pragma mark - _HGPropertyRef NSNumber helpers

@interface NSNumber (_HGPropertyRef)
-(HGFloat)hg_HGFloatValue;
@end

@implementation NSNumber (_HGPropertyRef)

- (HGFloat)hg_HGFloatValue
{
    if (strcmp(@encode(HGFloat), @encode(float)) == 0)
    {
        return [self floatValue];
    }
    return [self doubleValue];
}

@end

#pragma mark - _HGPropertyRef

struct _HGPropertyRef
{
    HGParticleSystemPropertyOption _option;
    
    HGFloat _constant1;
    HGFloat _constant2;
    HGFloat _constant3;
    HGFloat _constant4;
    HGFloat _constant5;
    HGFloat _constant6;
    HGFloat _constant7;
    HGFloat _constant8;
    
    HGLookupTableRef _curveLUT;
    
    GLKVector4 _color1Vector;
    GLKVector4 _color2Vector;
    
    HGLookupTableRef _gradientLUT;
};

HGPropertyRef HGPropertyMakeWithDictionary(const CFDictionaryRef dictionary)
{
    NSCAssert(dictionary, @"HGPropertyRef: Empty dictionary");
    
    struct _HGPropertyRef *ref = calloc(1, sizeof(struct _HGPropertyRef));
    if (ref == NULL) return NULL; // memory problem
    
    id value, option;
    
    id valueClass = CFDictionaryGetValue(dictionary, @"valueClass");
    if (valueClass)
    {
        value = (__bridge id)dictionary;
        if ([valueClass isEqualToString:@"HGCurve"])
        {
            option = HGPropertyValueOptionCurve;
        }
        else if ([valueClass isEqualToString:@"HGGradient"])
        {
            option = HGPropertyValueOptionGradient;
        }
    }
    else
    {
        value = CFDictionaryGetValue(dictionary, @"value");
        
        option = CFDictionaryGetValue(dictionary, @"option");
        HGAssert(option, @"HGParticleSystemProperty: missing <option>.");
    }
    HGAssert(value, @"HGParticleSystemProperty: missing <value>.");
    
    ref->_option = HGParticleSystemPropertyOptionFromString(option);
    HGAssert(ref->_option != NSNotFound, @"HGParticleSystemProperty: unsupported <option> value: %@", option);
    
    // helper block
    HGFloat (^HGFloatFromId)(id) = ^HGFloat(id obj) {
        HGAssert([obj isKindOfClass:NSNumber.class], @"HGParticleSystemProperty: object does not contain an NSNumber: %@", obj);
        return [obj hg_HGFloatValue];
    };
    
    // parse
    id lutDictionary;
    NSArray *constants;
    HGColor *color;
    switch (ref->_option) {
        case HGParticleSystemPropertyOptionConstant:
            // expecting an NSNumber
            ref->_constant1 = HGFloatFromId(value);
            break;
        case HGParticleSystemPropertyOptionCurve:
            // expecting a HGCurve as a dictionary, HGCurve performs its own assertions
            lutDictionary = value[@"lut"];
            if (lutDictionary)
            {
                ref->_curveLUT = HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)lutDictionary);
            }
            break;
        case HGParticleSystemPropertyOptionRandomConstants:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionRandomConstants");
            constants = value;
            HGAssert(constants.count == 2, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionRandomConstants");
            ref->_constant1 = HGFloatFromId(constants[0]);
            ref->_constant2 = HGFloatFromId(constants[1]);
            break;
        case HGParticleSystemPropertyOptionColor:
            // expecting an NSColor as a dictionary
            color = HGColorMakeWithDictionary(value);
            ref->_color1Vector = HGGLKVector4MakeWithColor(color);
            break;
        case HGParticleSystemPropertyOptionColorRandomRGB:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionColorRandomRGB");
            constants = value;
            HGAssert(constants.count == 8, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionColorRandomRGB");
            ref->_constant1 = HGFloatFromId(constants[0]);
            ref->_constant2 = HGFloatFromId(constants[1]);
            ref->_constant3 = HGFloatFromId(constants[2]);
            ref->_constant4 = HGFloatFromId(constants[3]);
            ref->_constant5 = HGFloatFromId(constants[4]);
            ref->_constant6 = HGFloatFromId(constants[5]);
            ref->_constant7 = HGFloatFromId(constants[6]);
            ref->_constant8 = HGFloatFromId(constants[7]);
            break;
        case HGParticleSystemPropertyOptionColorRandomHSV:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionColorRandomHSV");
            constants = value;
            HGAssert(constants.count == 8, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionColorRandomHSV");
            ref->_constant1 = HGFloatFromId(constants[0]);
            ref->_constant2 = HGFloatFromId(constants[1]);
            ref->_constant3 = HGFloatFromId(constants[2]);
            ref->_constant4 = HGFloatFromId(constants[3]);
            ref->_constant5 = HGFloatFromId(constants[4]);
            ref->_constant6 = HGFloatFromId(constants[5]);
            ref->_constant7 = HGFloatFromId(constants[6]);
            ref->_constant8 = HGFloatFromId(constants[7]);
            break;
        case HGParticleSystemPropertyOptionGradient:
            // expecting a HGGradient as a dictionary
            lutDictionary = value[@"lut"];
            if (lutDictionary)
            {
                ref->_gradientLUT = HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)lutDictionary);
            }
            break;
        case HGParticleSystemPropertyOptionRandomColors:
            // expecting an array with two NSColors as dictionaries
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionRandomColors");
            constants = value;
            HGAssert(constants.count == 2, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionRandomConstants");
            color = HGColorMakeWithDictionary(constants[0]);
            ref->_color1Vector = HGGLKVector4MakeWithColor(color);
            
            color = HGColorMakeWithDictionary(constants[1]);
            ref->_color2Vector = HGGLKVector4MakeWithColor(color);
            break;
            
        default: // Unsupported (yet) options go here
            break;
    }

    return ref;
}

void HGPropertyRelease(HGPropertyRef property)
{
    struct _HGPropertyRef * p = (struct _HGPropertyRef *)property;
    if (p)
    {
        if (p->_curveLUT)
        {
            HGLookupTableRelease(p->_curveLUT);
        }
        if (p->_gradientLUT)
        {
            HGLookupTableRelease(p->_gradientLUT);
        }
        free(p);
    }
}

HGParticleSystemPropertyOption HGPropertyGetOption(HGPropertyRef property)
{
    NSCAssert(property, @"HGPropertyGetOption: NULL property.");
    return property->_option;
}

HGFloat HGPropertyGetFloatValue(HGPropertyRef property, const HGFloat t)
{
    NSCAssert(property, @"HGPropertyFloatValue: NULL property.");
    switch (property->_option) {
        case HGParticleSystemPropertyOptionConstant:
            return property->_constant1;
        case HGParticleSystemPropertyOptionCurve:
            return HGLookupTableGetCGFloatValue(property->_curveLUT, t);
        case HGParticleSystemPropertyOptionRandomConstants:
            return RANDOM_CGFLOAT_IN_RANGE(property->_constant1, property->_constant2);
        default:
            break;
    }
    return NAN;
}

GLKVector4 HGPropertyGetGLKVector4Value(HGPropertyRef property, const HGFloat t)
{
    NSCAssert(property, @"HGPropertyGetGLKVector4Value: NULL property.");
    HGColor *color;
    switch (property->_option) {
        case HGParticleSystemPropertyOptionColor:
            return property->_color1Vector;
            break;
        case HGParticleSystemPropertyOptionColorRandomRGB:
            return GLKVector4Make(RANDOM_FLOAT_IN_RANGE(property->_constant1, property->_constant2),
                                  RANDOM_FLOAT_IN_RANGE(property->_constant3, property->_constant4),
                                  RANDOM_FLOAT_IN_RANGE(property->_constant5, property->_constant6),
                                  RANDOM_FLOAT_IN_RANGE(property->_constant7, property->_constant8));
            break;
        case HGParticleSystemPropertyOptionColorRandomHSV:
            color = [HGColor colorWithHue:RANDOM_CGFLOAT_IN_RANGE(property->_constant1, property->_constant2)
                               saturation:RANDOM_CGFLOAT_IN_RANGE(property->_constant3, property->_constant4)
                               brightness:RANDOM_CGFLOAT_IN_RANGE(property->_constant5, property->_constant6)
                                    alpha:RANDOM_CGFLOAT_IN_RANGE(property->_constant7, property->_constant8)];
            return HGGLKVector4MakeWithColor(color);
            break;
        case HGParticleSystemPropertyOptionGradient:
            return HGLookupTableGetGLKVector4Value(property->_gradientLUT, t);
            break;
        case HGParticleSystemPropertyOptionRandomColors:
            return GLKVector4Make(RANDOM_FLOAT_IN_RANGE(property->_color1Vector.r, property->_color2Vector.r),
                                  RANDOM_FLOAT_IN_RANGE(property->_color1Vector.g, property->_color2Vector.g),
                                  RANDOM_FLOAT_IN_RANGE(property->_color1Vector.b, property->_color2Vector.b),
                                  RANDOM_FLOAT_IN_RANGE(property->_color1Vector.a, property->_color2Vector.a));
            break;
        default:
            break;
    }
    return HGGLKVector4None;
}

CFDictionaryRef HGPropertyCreateDictionaryRepresentation(HGPropertyRef property)
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"_option"] = @(property->_option);
    dictionary[@"_constant1"] = @(property->_constant1);
    dictionary[@"_constant2"] = @(property->_constant2);
    dictionary[@"_constant3"] = @(property->_constant3);
    dictionary[@"_constant4"] = @(property->_constant4);
    dictionary[@"_constant5"] = @(property->_constant5);
    dictionary[@"_constant6"] = @(property->_constant6);
    dictionary[@"_constant7"] = @(property->_constant7);
    dictionary[@"_constant8"] = @(property->_constant8);
    
    dictionary[@"_color1Vector"] = [NSValue valueWithBytes:&property->_color1Vector objCType:@encode(GLKVector4)];
    dictionary[@"_color2Vector"] = [NSValue valueWithBytes:&property->_color2Vector objCType:@encode(GLKVector4)];
    
    if (property->_curveLUT)
    {
        dictionary[@"_curveLUT"] = CFBridgingRelease(HGLookupTableCreateDictionaryRepresentation(property->_curveLUT));
    }

    if (property->_gradientLUT)
    {
        dictionary[@"_gradientLUT"] = CFBridgingRelease(HGLookupTableCreateDictionaryRepresentation(property->_gradientLUT));
    }

    return (__bridge_retained CFDictionaryRef)dictionary;
}

HGPropertyRef HGPropertyMakeWithDictionaryRepresentation(const CFDictionaryRef dict)
{
    NSCAssert(dict, @"HGPropertyRef: Empty dictionary");
    
    struct _HGPropertyRef *ref = calloc(1, sizeof(struct _HGPropertyRef));
    if (ref == NULL) return NULL; // memory problem
    
    NSDictionary *dictionary = (__bridge NSDictionary *)dict;
    NSValue *v;
    
    v  = dictionary[@"_option"];
    [v getValue:&ref->_option];
    v  = dictionary[@"_constant1"];
    [v getValue:&ref->_constant1];
    v  = dictionary[@"_constant2"];
    [v getValue:&ref->_constant2];
    v  = dictionary[@"_constant3"];
    [v getValue:&ref->_constant3];
    v  = dictionary[@"_constant4"];
    [v getValue:&ref->_constant4];
    v  = dictionary[@"_constant5"];
    [v getValue:&ref->_constant5];
    v  = dictionary[@"_constant6"];
    [v getValue:&ref->_constant6];
    v  = dictionary[@"_constant7"];
    [v getValue:&ref->_constant7];
    v  = dictionary[@"_constant8"];
    [v getValue:&ref->_constant8];
    
    v  = dictionary[@"_color1Vector"];
    [v getValue:&ref->_color1Vector];
    v  = dictionary[@"_color2Vector"];
    [v getValue:&ref->_color2Vector];
    
    NSDictionary *d = dictionary[@"_curveLUT"];
    if (d) ref->_curveLUT = HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(d));

    d = dictionary[@"_gradientLUT"];
    if (d) ref->_gradientLUT = HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(d));

    return ref;
}
