/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "HGParticleSystemProperty.h"

// Helpers
#import "HGLookupTable_Private.h"

#ifndef HG_PROPERTY_CURVE_LUT_PRECISION
#define HG_PROPERTY_CURVE_LUT_PRECISION 32
#endif

#ifndef HG_PROPERTY_GRADIENT_LUT_PRECISION
#define HG_PROPERTY_GRADIENT_LUT_PRECISION 32
#endif

#ifndef RANDOM_CGFLOAT_IN_RANGE
#define RANDOM_CGFLOAT_IN_RANGE(min,max) ((CGFloat)arc4random()/UINT32_MAX) * ((max) - (min)) + (min)
#endif

#ifndef RANDOM_FLOAT_IN_RANGE
#define RANDOM_FLOAT_IN_RANGE(min,max) ((GLfloat)arc4random()/UINT32_MAX) * ((max) - (min)) + (min)
#endif

#ifndef HGAssert
#if NS_BLOCK_ASSERTIONS
#define HGAssert(expression, ...)
#else
#define HGAssert(expression, ...) \
    do { \
        if(!(expression)) { \
            NSLog(@"Assertion failure: %s in %s on line %s:%d. %@", #expression, __func__, __FILE__, __LINE__, [NSString stringWithFormat: @"" __VA_ARGS__]); \
            abort(); \
        } \
    } while(0)
#endif
#endif // ifndef HGAssert

FOUNDATION_STATIC_INLINE GLKVector3 HGGLKVector3MakeWithColor(HGColor *color)
{
    CGFloat components[4];
    [color getRed:components green:components+1 blue:components+2 alpha:components+3];
    return GLKVector3Make(components[0], components[1], components[2]);
}

#pragma mark - Options

NSString * const HGPropertyValueOptionConstant = @"HGPropertyValueOptionConstant";
NSString * const HGPropertyValueOptionCurve = @"HGPropertyValueOptionCurve";
NSString * const HGPropertyValueOptionRandomConstants = @"HGPropertyValueOptionRandomConstants";
NSString * const HGPropertyValueOptionRandomCurve = @"HGPropertyValueOptionRandomCurve";

NSString * const HGPropertyValueOptionColor = @"HGPropertyValueOptionColor";
NSString * const HGPropertyValueOptionColorRandomRGB = @"HGPropertyValueOptionColorRandomRGB";
NSString * const HGPropertyValueOptionColorRandomHSV = @"HGPropertyValueOptionColorRandomHSV";
NSString * const HGPropertyValueOptionGradient = @"HGPropertyValueOptionGradient";
NSString * const HGPropertyValueOptionRandomColors = @"HGPropertyValueOptionRandomColors";
NSString * const HGPropertyValueOptionRandomGradients = @"HGPropertyValueOptionRandomGradients";

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

HGParticleSystemPropertyOption _HGParticleSystemPropertyOptionFromString (NSString *string)
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
    id value = propertiesDictionary[string];
    if (value)
        return [value integerValue];
    
    return HGParticleSystemPropertyOptionUndefined;
}

#pragma mark - _HGPropertyRef NSNumber helpers

@interface NSNumber (_HGPropertyRef)
-(GLfloat)hg_GLfloatValue;
@end

@implementation NSNumber (_HGPropertyRef)

- (GLfloat)hg_GLfloatValue
{
    if (strcmp(@encode(GLfloat), @encode(float)) == 0)
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
    
    GLfloat _constant1;
    GLfloat _constant2;
    GLfloat _constant3;
    GLfloat _constant4;
    GLfloat _constant5;
    GLfloat _constant6;
    
    HGLookupTableRef _curveLUT;
    
    GLKVector3 _color1Vector;
    GLKVector3 _color2Vector;
    
    HGLookupTableRef _gradientLUT;
};

// private helper
struct _HGPropertyRef * _HGPropertyMake(HGParticleSystemPropertyOption option)
{
    NSCAssert(option != HGParticleSystemPropertyOptionUndefined, @"HGPropertyRef: invalid option");
    
    struct _HGPropertyRef *ref = calloc(1, sizeof(struct _HGPropertyRef));
    if (ref == NULL) return NULL; // memory problem
    
    ref->_option = option;
    
    return ref;
}

HGPropertyRef HGPropertyMakeWithConstant(const GLfloat constant)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionConstant);
    if (ref)
    {
        ref->_constant1 = constant;
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithRandomConstants(const GLfloat constant1, const GLfloat constant2)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionRandomConstants);
    if (ref)
    {
        ref->_constant1 = constant1;
        ref->_constant2 = constant2;
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithCurve(const HGLookupTableRef lut)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionCurve);
    if (ref)
    {
        CFDictionaryRef dictionary = _HGLookupTableCreateDictionaryRepresentation(lut);
        ref->_curveLUT = _HGLookupTableMakeWithDictionaryRepresentation(dictionary);
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithColor(HGColor *color)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionColor);
    if (ref)
    {
        ref->_color1Vector = HGGLKVector3MakeWithColor(color);
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithRandomColor(HGColor *color1, HGColor *color2)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionRandomColors);
    if (ref)
    {
        ref->_color1Vector = HGGLKVector3MakeWithColor(color1);
        ref->_color2Vector = HGGLKVector3MakeWithColor(color2);
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithColorRandomRGB(const GLfloat r1, const GLfloat r2, const GLfloat g1, const GLfloat g2, const GLfloat b1, const GLfloat b2)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionColorRandomRGB);
    if (ref)
    {
        ref->_constant1 = r1;
        ref->_constant2 = r2;
        ref->_constant3 = g1;
        ref->_constant4 = g2;
        ref->_constant5 = b1;
        ref->_constant6 = b2;
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithColorRandomHSV(const GLfloat h1, const GLfloat h2, const GLfloat s1, const GLfloat s2, const GLfloat v1, const GLfloat v2)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionColorRandomHSV);
    if (ref)
    {
        ref->_constant1 = h1;
        ref->_constant2 = h2;
        ref->_constant3 = s1;
        ref->_constant4 = s2;
        ref->_constant5 = v1;
        ref->_constant6 = v2;
    }
    return ref;
}

HGPropertyRef HGPropertyMakeWithGradient(const HGLookupTableRef lut)
{
    struct _HGPropertyRef *ref = _HGPropertyMake(HGParticleSystemPropertyOptionGradient);
    if (ref)
    {
        CFDictionaryRef dictionary = _HGLookupTableCreateDictionaryRepresentation(lut);
        ref->_curveLUT = _HGLookupTableMakeWithDictionaryRepresentation(dictionary);
    }
    return ref;
}

HGPropertyRef _HGPropertyMakeWithDictionary(const CFDictionaryRef dictionary)
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
    
    ref->_option = _HGParticleSystemPropertyOptionFromString(option);
    HGAssert(ref->_option != HGParticleSystemPropertyOptionUndefined, @"HGParticleSystemProperty: unsupported <option> value: %@", option);
    
    // helper block
    GLfloat (^GLfloatFromId)(id) = ^GLfloat(id obj) {
        HGAssert([obj isKindOfClass:NSNumber.class], @"HGParticleSystemProperty: object does not contain an NSNumber: %@", obj);
        return [obj hg_GLfloatValue];
    };
    
    // parse
    id lutDictionary;
    NSArray *constants;
    HGColor *color;
    switch (ref->_option) {
        case HGParticleSystemPropertyOptionConstant:
            // expecting an NSNumber
            ref->_constant1 = GLfloatFromId(value);
            break;
        case HGParticleSystemPropertyOptionCurve:
            // expecting a HGCurve as a dictionary, HGCurve performs its own assertions
            lutDictionary = value[@"lut"];
            if (lutDictionary)
            {
                ref->_curveLUT = _HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)lutDictionary);
            }
            break;
        case HGParticleSystemPropertyOptionRandomConstants:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionRandomConstants");
            constants = value;
            HGAssert(constants.count == 2, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionRandomConstants");
            ref->_constant1 = GLfloatFromId(constants[0]);
            ref->_constant2 = GLfloatFromId(constants[1]);
            break;
        case HGParticleSystemPropertyOptionColor:
            // expecting an NSColor as a dictionary
            color = HGColorMakeWithDictionary(value);
            ref->_color1Vector = HGGLKVector3MakeWithColor(color);
            break;
        case HGParticleSystemPropertyOptionColorRandomRGB:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionColorRandomRGB");
            constants = value;
            HGAssert(constants.count == 6, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionColorRandomRGB");
            ref->_constant1 = GLfloatFromId(constants[0]);
            ref->_constant2 = GLfloatFromId(constants[1]);
            ref->_constant3 = GLfloatFromId(constants[2]);
            ref->_constant4 = GLfloatFromId(constants[3]);
            ref->_constant5 = GLfloatFromId(constants[4]);
            ref->_constant6 = GLfloatFromId(constants[5]);
            break;
        case HGParticleSystemPropertyOptionColorRandomHSV:
            // expecting an array with two NSNumbers
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionColorRandomHSV");
            constants = value;
            HGAssert(constants.count == 6, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionColorRandomHSV");
            ref->_constant1 = GLfloatFromId(constants[0]);
            ref->_constant2 = GLfloatFromId(constants[1]);
            ref->_constant3 = GLfloatFromId(constants[2]);
            ref->_constant4 = GLfloatFromId(constants[3]);
            ref->_constant5 = GLfloatFromId(constants[4]);
            ref->_constant6 = GLfloatFromId(constants[5]);
            break;
        case HGParticleSystemPropertyOptionGradient:
            // expecting a HGGradient as a dictionary
            lutDictionary = value[@"lut"];
            if (lutDictionary)
            {
                ref->_gradientLUT = _HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)lutDictionary);
            }
            break;
        case HGParticleSystemPropertyOptionRandomColors:
            // expecting an array with two NSColors as dictionaries
            HGAssert([value isKindOfClass:NSArray.class], @"HGParticleSystemProperty: wrong value class for HGParticleSystemPropertyOptionRandomColors");
            constants = value;
            HGAssert(constants.count == 2, @"HGParticleSystemProperty: wrong value count for HGParticleSystemPropertyOptionRandomConstants");
            color = HGColorMakeWithDictionary(constants[0]);
            ref->_color1Vector = HGGLKVector3MakeWithColor(color);
            
            color = HGColorMakeWithDictionary(constants[1]);
            ref->_color2Vector = HGGLKVector3MakeWithColor(color);
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

GLfloat HGPropertyGetFloatValue(HGPropertyRef property, const GLfloat t)
{
    NSCAssert(property, @"HGPropertyFloatValue: NULL property.");
    switch (property->_option) {
        case HGParticleSystemPropertyOptionConstant:
            return property->_constant1;
        case HGParticleSystemPropertyOptionCurve:
            return HGLookupTableGetCGFloatValue(property->_curveLUT, t);
        case HGParticleSystemPropertyOptionRandomConstants:
            return RANDOM_FLOAT_IN_RANGE(property->_constant1, property->_constant2);
        default:
            break;
    }
    return NAN;
}

GLKVector3 HGPropertyGetGLKVector3Value(HGPropertyRef property, const GLfloat t)
{
    NSCAssert(property, @"HGPropertyGetGLKVector4Value: NULL property.");
    HGColor *color;
    switch (property->_option) {
        case HGParticleSystemPropertyOptionColor:
            return property->_color1Vector;
            break;
        case HGParticleSystemPropertyOptionColorRandomRGB:
            return GLKVector3Make(RANDOM_FLOAT_IN_RANGE(property->_constant1, property->_constant2),
                                  RANDOM_FLOAT_IN_RANGE(property->_constant3, property->_constant4),
                                  RANDOM_FLOAT_IN_RANGE(property->_constant5, property->_constant6));
            break;
        case HGParticleSystemPropertyOptionColorRandomHSV:
            color = [HGColor colorWithHue:RANDOM_CGFLOAT_IN_RANGE(property->_constant1, property->_constant2)
                               saturation:RANDOM_CGFLOAT_IN_RANGE(property->_constant3, property->_constant4)
                               brightness:RANDOM_CGFLOAT_IN_RANGE(property->_constant5, property->_constant6)
                                    alpha:1.f];
            return HGGLKVector3MakeWithColor(color);
            break;
        case HGParticleSystemPropertyOptionGradient:
            return HGLookupTableGetGLKVector3Value(property->_gradientLUT, t);
            break;
        case HGParticleSystemPropertyOptionRandomColors:
            return GLKVector3Make(RANDOM_FLOAT_IN_RANGE(property->_color1Vector.r, property->_color2Vector.r),
                                  RANDOM_FLOAT_IN_RANGE(property->_color1Vector.g, property->_color2Vector.g),
                                  RANDOM_FLOAT_IN_RANGE(property->_color1Vector.b, property->_color2Vector.b));
            break;
        default:
            break;
    }
    return (GLKVector3){0.f, 0.f, 0.f};
}

CFDictionaryRef _HGPropertyCreateDictionaryRepresentation(HGPropertyRef property)
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"_option"] = @(property->_option);
    dictionary[@"_constant1"] = @(property->_constant1);
    dictionary[@"_constant2"] = @(property->_constant2);
    dictionary[@"_constant3"] = @(property->_constant3);
    dictionary[@"_constant4"] = @(property->_constant4);
    dictionary[@"_constant5"] = @(property->_constant5);
    dictionary[@"_constant6"] = @(property->_constant6);
    
    dictionary[@"_color1Vector"] = [NSValue valueWithBytes:&property->_color1Vector objCType:@encode(GLKVector4)];
    dictionary[@"_color2Vector"] = [NSValue valueWithBytes:&property->_color2Vector objCType:@encode(GLKVector4)];
    
    if (property->_curveLUT)
    {
        dictionary[@"_curveLUT"] = CFBridgingRelease(_HGLookupTableCreateDictionaryRepresentation(property->_curveLUT));
    }

    if (property->_gradientLUT)
    {
        dictionary[@"_gradientLUT"] = CFBridgingRelease(_HGLookupTableCreateDictionaryRepresentation(property->_gradientLUT));
    }

    return (__bridge_retained CFDictionaryRef)dictionary;
}

HGPropertyRef _HGPropertyMakeWithDictionaryRepresentation(const CFDictionaryRef dict)
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
    
    v  = dictionary[@"_color1Vector"];
    [v getValue:&ref->_color1Vector];
    v  = dictionary[@"_color2Vector"];
    [v getValue:&ref->_color2Vector];
    
    NSDictionary *d = dictionary[@"_curveLUT"];
    if (d) ref->_curveLUT = _HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(d));

    d = dictionary[@"_gradientLUT"];
    if (d) ref->_gradientLUT = _HGLookupTableMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(d));

    return ref;
}
