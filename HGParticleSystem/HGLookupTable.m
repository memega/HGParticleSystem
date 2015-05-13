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

FOUNDATION_STATIC_INLINE GLfloat GLfloatLerp(GLfloat a, GLfloat b, GLfloat ratio)
{
    return (b - a) * ratio + a;
}

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
    GLfloat _min;
    GLfloat _max;
    void * _values; // either GLfloat or GLKVector4 depending on _type
};

HGLookupTableRef HGLookupTableMakeWithFloat(const GLfloat *values, const size_t size, const GLfloat min, const GLfloat max)
{
    NSCAssert(size > 0, @"HGLookupTableRef initializer: zero size.");
    NSCAssert(values, @"HGLookupTableRef initializer: NULL array.");
    
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL) return NULL;
    
    ref->_values = calloc(size, sizeof(GLfloat));
    if (ref->_values == NULL)
    {
        free(ref);
        return NULL;
    }
    
    memcpy(ref->_values, values, size * sizeof(GLfloat));
    
    ref->_size = size;
    ref->_min = min;
    ref->_max = max;
    
    ref->_type = _HGLookupTableValueTypeFloat;
    
    return ref;
}

HGLookupTableRef HGLookupTableMakeWithGLKVector4(const GLKVector4 *values, const size_t size)
{
    NSCAssert(size > 0, @"HGLookupTableRef initializer: zero size.");
    NSCAssert(values, @"HGLookupTableRef initializer: NULL array.");
    
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL) return NULL;
    
    ref->_values = calloc(size, sizeof(GLKVector4));
    if (ref->_values == NULL)
    {
        free(ref);
        return NULL;
    }
    
    memcpy(ref->_values, values, size * sizeof(GLKVector4));
    
    ref->_size = size;
    
    ref->_type = _HGLookupTableValueTypeGLKVector4;

    return ref;
}

void HGLookupTableRelease(HGLookupTableRef lut)
{
    struct _HGLookupTableRef *p = (struct _HGLookupTableRef *)lut;
    if (p)
    {
        if (p->_values) free(p->_values);
        free(p);
    }
}

GLfloat HGLookupTableGetCGFloatValue(HGLookupTableRef lut, GLfloat t)
{
    NSCAssert(lut, @"HGLookupTableRef: NULL LUT");
    NSCAssert(lut->_type == _HGLookupTableValueTypeFloat, @"HGLookupTableRef: LUT does not contain float values.");
    
    GLfloat *values = lut->_values;
    
    if (lut->_size == 1)
    {
        return values[0];
    }
    
    if (t <= 0.0)
    {
        return GLfloatLerp(lut->_min, lut->_max, values[0]);
    }
    if (t >= 1.0)
    {
        return GLfloatLerp(lut->_min, lut->_max, values[lut->_size - 1]);
    }
    
    if (lut->_size == 2)
    {
        return GLfloatLerp(lut->_min, lut->_max, GLfloatLerp(values[0], values[1], t));
    }
    
    GLfloat floatIndex = t * (lut->_size - 1);
    NSUInteger index = (NSUInteger)floatIndex;
    GLfloat v1 = values[index];
    if (floatIndex - index == 0.)
        return v1;
    
    GLfloat v2 = values[index + 1];
    return GLfloatLerp(lut->_min, lut->_max, GLfloatLerp(v1, v2, t * lut->_size - index));
}

GLKVector3 HGLookupTableGetGLKVector3Value(HGLookupTableRef lut, const GLfloat t)
{
    GLKVector4 value = HGLookupTableGetGLKVector4Value(lut, t);
    return GLKVector3Make(value.x, value.y, value.z);
}

GLKVector4 HGLookupTableGetGLKVector4Value(HGLookupTableRef lut, GLfloat t)
{
    NSCAssert(lut, @"HGLookupTableRef: NULL LUT");
    NSCAssert(lut->_type == _HGLookupTableValueTypeGLKVector4, @"HGLookupTableRef: LUT does not contain GLKVector4 values.");

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
    
    GLfloat floatIndex = t * (lut->_size - 1);
    NSUInteger index = (NSUInteger)floatIndex;
    GLKVector4 v1 = values[index];
    if (floatIndex - index == 0.)
        return v1;
    
    GLKVector4 v2 = values[index + 1];
    return GLKVector4Lerp(v1, v2, t * lut->_size - index);
}

CFDictionaryRef _HGLookupTableCreateDictionaryRepresentation(HGLookupTableRef lut)
{
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"_type"] = @(lut->_type);
    dictionary[@"_size"] = @(lut->_size);
    dictionary[@"_min"] = @(lut->_min);
    dictionary[@"_max"] = @(lut->_max);
    
    NSMutableArray *values = NSMutableArray.array;
    if (lut->_type == _HGLookupTableValueTypeFloat)
    {
        GLfloat *scalarValues = lut->_values;
        for (NSUInteger i = 0; i<lut->_size; i++)
        {
            GLfloat scalarValue = *(scalarValues + i);
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

HGLookupTableRef _HGLookupTableMakeWithDictionaryRepresentation(CFDictionaryRef dict)
{
    struct _HGLookupTableRef *ref = calloc(1, sizeof(struct _HGLookupTableRef));
    if (ref == NULL) return NULL;
    
    NSDictionary *dictionary = (__bridge NSDictionary*)dict;
    NSValue * value;
    NSNumber *number;
    
    value = dictionary[@"_size"];
    [value getValue:&ref->_size];

    NSCAssert(ref->_size > 0, @"HGLookupTableMakeWithDictionaryRepresentation: zero size.");
    
    value = dictionary[@"_type"];
    [value getValue:&ref->_type];
    
    NSArray *array = dictionary[@"_values"];
    if (ref->_type == _HGLookupTableValueTypeFloat)
    {
        GLfloat *scalarValues = calloc(ref->_size, sizeof(GLfloat));
        if (scalarValues == NULL)
        {
            free(ref);
            return NULL;
        }
        
        for(NSUInteger i = 0; i<array.count; i++)
        {
            number = array[i];
            scalarValues[i] = (GLfloat)[number floatValue];
        }
        ref->_values = scalarValues;
        
        number = dictionary[@"_min"];
        ref->_min = (GLfloat)[number floatValue];
        number = dictionary[@"_max"];
        ref->_max = (GLfloat)[number floatValue];
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
        
        number = dictionary[@"_min"];
        ref->_min = (GLfloat)[number floatValue];
        number = dictionary[@"_max"];
        ref->_max = (GLfloat)[number floatValue];
    }
    
    return ref;
}