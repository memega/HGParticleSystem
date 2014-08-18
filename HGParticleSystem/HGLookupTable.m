//
//  HGLookupTable.m
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 10/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import "HGLookupTable.h"

//    // lookup table resolution
//    int L = points.length;
//    order = L-1;
//    LUT_resolution = 1 + (int) (400 * log(order)/log(4));

#pragma mark - LUT

typedef NS_ENUM(uint8_t, _HGLookupTableValueType)
{
    _HGLookupTableValueTypeFloat,
    _HGLookupTableValueTypeGLKVector4,
};

struct _HGLookupTableRef
{
    _HGLookupTableValueType _type;
    size_t _size;
    HGFloat _min;
    HGFloat _max;
    void * _values; // either HGFloat or GLKVector4 depending on _type
};

HGLookupTableRef HGLookupTableMakeWithFloat(const HGFloat *values, const size_t size, const HGFloat min, const HGFloat max)
{
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL)
    {
        return NULL;
    }
    
    NSCAssert(size > 0, @"HGLookupTableRef initializer: zero size.");
    NSCAssert(values, @"HGLookupTableRef initializer: NULL array.");

    ref->_values = calloc(size, sizeof(HGFloat));
    if (ref->_values == NULL)
    {
        free(ref);
        return NULL;
    }
    
    memcpy(ref->_values, values, size * sizeof(HGFloat));
    
    ref->_size = size;
    ref->_min = min;
    ref->_max = max;
    
    ref->_type = _HGLookupTableValueTypeFloat;
    
    return ref;
}

HGLookupTableRef HGLookupTableMakeWithGLKVector4(const GLKVector4 *values, const size_t size)
{
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL)
    {
        return NULL;
    }
    
    NSCAssert(size > 0, @"HGLookupTableRef initializer: zero size.");
    NSCAssert(values, @"HGLookupTableRef initializer: NULL array.");
    
    ref->_values = calloc(size, sizeof(GLKVector4));
    if (ref->_values == NULL)
        return nil;
    
    memcpy(ref->_values, values, size * sizeof(GLKVector4));
    
    ref->_size = size;
    
    ref->_type = _HGLookupTableValueTypeGLKVector4;

    return ref;
}

void HGLookupTableRelease(HGLookupTableRef lut)
{
    if (lut)
    {
        if (lut->_values) free(lut->_values);
        free((struct _HGLookupTableRef *)lut);
    }
}

HGFloat HGLookupTableGetCGFloatValue(HGLookupTableRef lut, HGFloat t)
{
    NSCAssert(lut, @"HGLookupTableRef: NULL LUT");
    NSCAssert(lut->_type == _HGLookupTableValueTypeFloat, @"HGLookupTableRef: LUT provided does not contain float values.");
    
    HGFloat *values = lut->_values;
    
    if (lut->_size == 1)
    {
        return values[0];
    }
    
    if (t <= 0.0)
    {
        return HGFloatLerp(lut->_min, lut->_max, values[0]);
    }
    if (t >= 1.0)
    {
        return HGFloatLerp(lut->_min, lut->_max, values[lut->_size - 1]);
    }
    
    if (lut->_size == 2)
    {
        return HGFloatLerp(lut->_min, lut->_max, HGFloatLerp(values[0], values[1], t));
    }
    
    HGFloat floatIndex = t * (lut->_size - 1);
    NSUInteger index = (NSUInteger)floatIndex;
    HGFloat v1 = values[index];
    if (floatIndex - index == 0.)
        return v1;
    
    HGFloat v2 = values[index + 1];
    return HGFloatLerp(lut->_min, lut->_max, HGFloatLerp(v1, v2, t * lut->_size - index));
}

GLKVector4 HGLookupTableGetGLKVector4Value(HGLookupTableRef lut, HGFloat t)
{
    NSCAssert(lut, @"HGLookupTableRef: NULL LUT");
    NSCAssert(lut->_type == _HGLookupTableValueTypeGLKVector4, @"HGLookupTableRef: LUT provided does not contain GLKVector4 values.");

    GLKVector4 *values = lut->_values;

    if (lut->_size == 1)
    {
        return values[0];
    }
    
    if (t <= 0.0)
    {
        return values[0];
    }
    if (t >= 1.0)
    {
        return values[lut->_size - 1];
    }
    
    if (lut->_size == 2)
    {
        return GLKVector4Lerp(values[0], values[lut->_size - 1], t);
    }
    
    HGFloat floatIndex = t * (lut->_size - 1);
    NSUInteger index = (NSUInteger)floatIndex;
    GLKVector4 v1 = values[index];
    if (floatIndex - index == 0.)
        return v1;
    
    GLKVector4 v2 = values[index + 1];
    return GLKVector4Lerp(v1, v2, t * lut->_size - index);
}

CFDictionaryRef HGLookupTableCreateDictionaryRepresentation(HGLookupTableRef lut)
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"_type"] = @(lut->_type);
    dictionary[@"_size"] = @(lut->_size);
    dictionary[@"_min"] = @(lut->_min);
    dictionary[@"_max"] = @(lut->_max);
    
    NSMutableArray *values = NSMutableArray.array;
    if (lut->_type == _HGLookupTableValueTypeFloat)
    {
        HGFloat *scalarValues = lut->_values;
        for (NSUInteger i = 0; i<lut->_size; i++)
        {
            HGFloat scalarValue = scalarValues[i];
            [values addObject:@(scalarValue)];
        }
        dictionary[@"_values"] = values;
    }
    else if (lut->_type == _HGLookupTableValueTypeGLKVector4)
    {
        GLKVector4 *scalarValues = lut->_values;
        for (NSUInteger i = 0; i<lut->_size; i++)
        {
            GLKVector4 scalarValue = scalarValues[i];
            [values addObject:@{
                                @"X": @(scalarValue.x),
                                @"Y": @(scalarValue.y),
                                @"Y": @(scalarValue.z),
                                @"W": @(scalarValue.w),
                                }];
        }
        dictionary[@"_values"] = values;
    }
    
    return (__bridge_retained CFDictionaryRef)dictionary;
}

HGLookupTableRef HGLookupTableMakeWithDictionaryRepresentation(CFDictionaryRef dict)
{
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL)
    {
        return NULL;
    }
    
    NSDictionary *dictionary = (__bridge NSDictionary*)dict;
    NSValue * value;
    
    value = dictionary[@"_size"];
    [value getValue:&ref->_size];

    NSCAssert(ref->_size > 0, @"HGLookupTableMakeWithDictionaryRepresentation: zero size.");
    
    value = dictionary[@"_type"];
    [value getValue:&ref->_type];
    
    NSArray *array = dictionary[@"_values"];
    if (ref->_type == _HGLookupTableValueTypeFloat)
    {
        HGFloat *scalarValues = calloc(ref->_size, sizeof(HGFloat));
        if (scalarValues == NULL)
        {
            free(ref);
            return NULL;
        }
        
        HGFloat scalarValue;
        for(NSUInteger i = 0; i<array.count; i++)
        {
            value = array[i];
            [value getValue:&scalarValue];
            scalarValues[i] = scalarValue;
        }
        ref->_values = scalarValues;
        
        value = dictionary[@"_min"];
        [value getValue:&ref->_min];
        value = dictionary[@"_max"];
        [value getValue:&ref->_max];
    }
    else if (ref->_type == _HGLookupTableValueTypeGLKVector4)
    {
        GLKVector4 *scalarValues = calloc(ref->_size, sizeof(GLKVector4));
        if (scalarValues == NULL)
        {
            free(ref);
            return NULL;
        }
        
        for(NSUInteger i = 0; i<array.count; i++)
        {
            NSDictionary *dictionaryRepresentation = array[i];
            scalarValues[i] = GLKVector4Make([dictionaryRepresentation[@"X"] floatValue],
                                             [dictionaryRepresentation[@"Y"] floatValue],
                                             [dictionaryRepresentation[@"Z"] floatValue],
                                             [dictionaryRepresentation[@"W"] floatValue]);
        }
        ref->_values = scalarValues;
        
        value = dictionary[@"_min"];
        [value getValue:&ref->_min];
        value = dictionary[@"_max"];
        [value getValue:&ref->_max];
    }
    
    return ref;
}