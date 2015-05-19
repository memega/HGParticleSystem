//
//  HGParticleSystemProperty.h
//  HGParticleSystem
//
//  Created by Yuriy Panfyorov on 09/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGLookupTable.h"

#ifndef HGPSPR_
#define HGPSPR_

// color
#ifndef HGColor
    #ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        #define HGColor NSColor
    #else
        #define HGColor UIColor
    #endif
#endif

/**
 *  An opaque type that represents a dynamic property object. An HGPropertyRef object stores a value which may vary over time.
 */
typedef const struct _HGPropertyRef * HGPropertyRef;

/**
 *  Options which specify dynamic behavior for an HGPropertyRef object.
 */
typedef NS_ENUM(NSInteger, HGParticleSystemPropertyOption){
    /**
     *  The HGPropertyRef object contains a single constant value.
     */
    HGParticleSystemPropertyOptionConstant,
    /**
     *  The HGPropertyRef object contains a single float value which changes along a Bezier curve.
     */
    HGParticleSystemPropertyOptionCurve,
    /**
     *  The HGPropertyRef object contains a random float value evenly distributed between two float constants.
     */
    HGParticleSystemPropertyOptionRandomConstants,
    /**
     *  The HGPropertyRef object contains a constant color value.
     */
    HGParticleSystemPropertyOptionColor,
    /**
     *  The HGPropertyRef object contains a random color value evenly distributed between two RGB colors.
     */
    HGParticleSystemPropertyOptionColorRandomRGB,
    /**
     *  The HGPropertyRef object contains a random color value evenly distributed between two HSV colors.
     */
    HGParticleSystemPropertyOptionColorRandomHSV,
    /**
     *  The HGPropertyRef object contains a color value which changes along a gradient.
     */
    HGParticleSystemPropertyOptionGradient,
    /**
     *  The HGPropertyRef object contains a random color value evenly distributed between two colors.
     */
    HGParticleSystemPropertyOptionRandomColors,
    /**
     *  The HGPropertyRef object behavior is undefined.
     */
    HGParticleSystemPropertyOptionUndefined = NSNotFound
};

// set of single value dynamics options
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionConstant;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionCurve;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomConstants;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomCurve;

// set of color dynamics options
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColor;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColorRandomRGB;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionColorRandomHSV;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionGradient;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomColors;
FOUNDATION_EXPORT NSString * const HGPropertyValueOptionRandomGradients;

/**
 *  Creates a property object with a constant value.
 *
 *  @param constant The constant value to store.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithConstant(const GLfloat constant);
/**
 *  Creates a property object with values distributed randomly between two constants.
 *
 *  @param constant1 The first constant value of the random values range.
 *  @param constant2 The second constant value of the random values range.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithRandomConstants(const GLfloat constant1, const GLfloat constant2);
/**
 *  Creates a property object with values distributed along the given curve over time.
 *
 *  @param curveLUT The curve lookup table to store. See HGLookupTableRef for more details.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithCurve(const HGLookupTableRef curveLUT);
/**
 *  Creates a property object with a constant color value.
 *
 *  @param color The color object to store.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColor(HGColor *color);
/**
 *  Creates a property object with color values randomly distributed between two RGB colors.
 *
 *  @param r1 Red component of the first color.
 *  @param r2 Red component of the second color.
 *  @param g1 Green component of the first color.
 *  @param g2 Green component of the second color.
 *  @param b1 Blue component of the first color.
 *  @param b2 Blue component of the second color.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColorRandomRGB(const GLfloat r1, const GLfloat r2, const GLfloat g1, const GLfloat g2, const GLfloat b1, const GLfloat b2);
/**
 *  Creates a property object with color values randomly distributed between two HSV colors.
 *
 *  @param h1 Hue component of the first color.
 *  @param h2 Hue component of the second color.
 *  @param s1 Saturation component of the first color.
 *  @param s2 Saturation component of the second color.
 *  @param v1 Value component of the second color.
 *  @param v2 Value component of the second color.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithColorRandomHSV(const GLfloat h1, const GLfloat h2, const GLfloat s1, const GLfloat s2, const GLfloat v1, const GLfloat v2);
/**
 *  Creates a property object with color values distributed along a color gradient over time.
 *
 *  @param gradientLUT The gradient lookup table to store. See HGLookupTableRef for more details.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithGradient(const HGLookupTableRef gradientLUT);
/**
 *  Creates a property object with color values randomly distributed between two colors.
 *
 *  @param color1 First color object.
 *  @param color2 Second color object.
 *
 *  @return A new property object. You are responsible for releasing this object.
 */
FOUNDATION_EXPORT HGPropertyRef HGPropertyMakeWithRandomColor(HGColor *color1, HGColor *color2);

/**
 *  Releases an HGPropertyRef object.
 *
 *  @param property The HGPropertyRef object to release. This value must not be NULL.
 */
FOUNDATION_EXPORT void HGPropertyRelease(HGPropertyRef property);

/**
 *  Calculates a float value of an HGPropertyRef object for given t value, with t in range [0.0…1.0]. Use this function in order to determine a single float value for specific moment in time.
 *
 *  @param property A HGPropertyRef object. This value must not be NULL, and it must be created with one of the dynamics options available for float values: HGParticleSystemPropertyOptionConstant, HGParticleSystemPropertyOptionCurve, or HGParticleSystemPropertyOptionRandomConstants.
 *  @param t        t value, indicating property time. Must be in range [0.0…1.0].
 *
 *  @return The HGPropertyRef object's float value corresponding to the given t.
 */
FOUNDATION_EXPORT GLfloat HGPropertyGetFloatValue(HGPropertyRef property, const GLfloat t);
/**
 *  Calculates a GLKVector3 value of an HGPropertyRef object for given t value, with t in range [0.0…1.0]. Use this function in order to determine color values for certain moment in time.
 *
 *  @param property A HGPropertyRef object. This value must not be NULL, and it must be created with one of the dynamics options available for color values: HGParticleSystemPropertyOptionColor, HGParticleSystemPropertyOptionColorRandomRGB, HGParticleSystemPropertyOptionColorRandomHSV, or HGParticleSystemPropertyOptionGradient.
 *  @param t        t value, indicating property time. Must be in range [0.0…1.0].
 *
 *  @return The HGPropertyRef object's vector value corresponding to the given t.
 */
FOUNDATION_EXPORT GLKVector3 HGPropertyGetGLKVector3Value(HGPropertyRef property, const GLfloat t);
/**
 *  Returns the dynamics option of an HGPropertyRef object.
 *
 *  @param property The HGPropertyRef object to get option for.
 *
 *  @return Dynamics option of the HGPropertyRef object. See HGParticleSystemPropertyOption for more details.
 */
FOUNDATION_EXPORT HGParticleSystemPropertyOption HGPropertyGetOption(HGPropertyRef property);

#endif
