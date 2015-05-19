//
//  HGLookupTable.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 10/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#ifndef HGLUT_
#define HGLUT_

/**
 *  An opaque type that represents a simple lookup table. An HGLookupTableRef object stores a finite series of value representing a function f(x) and allows to calculate an approximation of the function for any x.
 */
typedef const struct _HGLookupTableRef * HGLookupTableRef;

/**
 *  Creates a lookup table object for a single float value function f(x). Provided values are expected to be a normalized representation of function over x range [0.0…1.0], with values in range [0.0…1.0]. The first value in the array is interpreted as f(0.0), and the last value in the array is interpreted as f(1.0). Output values extracted with HGLookupTableGetCGFloatValue will be linearly interpolated into range [min…max]. An array consisting of a single value represents a constant function y=const.
 *
 *  @discussion For example, creating a HGLookupTableRef object with values {0.0, 1.0}, min 0.0 and max 1.0 would yield a simple linear function y=x.
 *
 *  @param values An array of values in range [0.0…1.0] evenly distributed for x in range [0.0…1.0]. The original array is copied and can be freed. This value must not be NULL.
 *  @param size   Number of values in the array. This value must be greater than 0.
 *  @param min    Minimum value of the function, corresponding to value 0.0 in array.
 *  @param max    Maximum value of the function, corresponding to value 1.0 in array.
 *
 *  @return A new lookup table object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGLookupTableRef HGLookupTableMakeWithFloat(const GLfloat *values, const size_t size, const GLfloat min, const GLfloat max);
/**
 *  Creates a lookup table object for a vector function. First value in the array is interpreted as f(0.0), and last value in the array is interpreted as f(1.0). An array consisting of a single value represents a constant function y={const,const,const}.
 *
 *  @param values An array of vector function values evenly distributed for x in range [0.0…1.0]. The original array is copied and can be freed. This value must not be NULL.
 *  @param size   Number of values in the array. This value must be greater than 0.
 *
 *  @return A new lookup table object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGLookupTableRef HGLookupTableMakeWithGLKVector4(const GLKVector4 *values, const size_t size);

/**
 *  Releases an HGLookupTableRef object.
 *
 *  @param property The HGLookupTableRef object to release. This value must not be NULL.
 */
FOUNDATION_EXPORT void HGLookupTableRelease(HGLookupTableRef lut);

/**
 *  Calculates an approximation of function value for given x based on a lookup table function representation.
 *
 *  @param lut An HGLookupTableRef object containing numeric representation of a function. This value must not be NULL.
 *  @param x   x value
 *
 *  @return The lookup table value corresponding to the given x.
 */
FOUNDATION_EXPORT GLfloat HGLookupTableGetCGFloatValue(HGLookupTableRef lut, const GLfloat x);
/**
 *  Calculates an approximation of function value for given x based on a lookup table function representation.
 *
 *  @param lut An HGLookupTableRef object containing numeric representation of a vector function. This value must not be NULL.
 *  @param x   x value
 *
 *  @return The lookup table value corresponding to the given x.
 */
FOUNDATION_EXPORT GLKVector3 HGLookupTableGetGLKVector3Value(HGLookupTableRef lut, const GLfloat x);
/**
 *  Calculates an approximation of function value for given x based on a lookup table function representation.
 *
 *  @param lut An HGLookupTableRef object containing numeric representation of a vector function. This value must not be NULL.
 *  @param x   x value
 *
 *  @return The lookup table value corresponding to the given x.
 */
FOUNDATION_EXPORT GLKVector4 HGLookupTableGetGLKVector4Value(HGLookupTableRef lut, const GLfloat x);

#endif
