/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>

#if defined(__has_include)
#if !__has_include("cocos2d.h")

#ifndef CCLOG
#define CCLOG NSLog
#endif

#ifndef CCRANDOM_0_1
#define CCRANDOM_0_1() (0)
#endif

#ifndef CCRANDOM_MINUS1_1
#define CCRANDOM_MINUS1_1() (0)
#endif

#ifndef CC_DEGREES_TO_RADIANS
#define CC_DEGREES_TO_RADIANS(d) (d * M_PI / 180.0 )
#endif

FOUNDATION_EXPORT const NSString *CCBlendFuncSrcColor;
FOUNDATION_EXPORT const NSString *CCBlendFuncDstColor;

@interface CCDirector : NSObject
+ (instancetype)sharedDirector;
- (CGFloat)contentScaleFactor;
@end

@interface CCBlendMode : NSObject
+ (instancetype)premultipliedAlphaMode;
+ (instancetype)blendModeWithOptions:(id)options;
@end

@interface CCShader : NSObject
+ (instancetype)positionTextureColorShader;
@end

@interface CCTexture : NSObject
- (id)initWithCGImage:(CGImageRef)cgImage contentScale:(CGFloat)contentScale;
@property (nonatomic) CGFloat contentScale;
@property (nonatomic) CGFloat pixelWidth;
@property (nonatomic) CGFloat pixelHeight;
@property (nonatomic) CGSize contentSize;
@end

@interface CCRenderState : NSObject
@end

@interface CCNode : NSObject
{
    @protected
    CCNode *_parent;
    BOOL _visible;
}
- (void)removeFromParent;
- (void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup;
- (CGPoint)convertToWorldSpace:(CGPoint)point;
@property (nonatomic) CCBlendMode *blendMode;
@property (nonatomic) CCShader *shader;
@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL visible;
@property (nonatomic) CCTexture *texture;
@property (nonatomic) CCRenderState *renderState;
@end

@interface CCFileUtils : NSObject
+ (instancetype)sharedFileUtils;
-(NSString*) fullPathFromRelativePath:(NSString*) relPath;
-(NSString*) fullPathForFilename:(NSString*)filename;
@end

typedef NS_ENUM(NSUInteger, CCParticleSystemPositionType) {
	CCParticleSystemPositionTypeFree,
	CCParticleSystemPositionTypeRelative,
	CCParticleSystemPositionTypeGrouped,
};

typedef double CCTime;
typedef struct CCRenderBuffer {} CCRenderBuffer;
typedef struct CCVertex {
	GLKVector4 position;
	GLKVector2 texCoord1, texCoord2;
	GLKVector4 color;
} CCVertex;

static inline void CCRenderBufferSetVertex(CCRenderBuffer buffer, int index, CCVertex vertex) {};
static inline void CCRenderBufferSetTriangle(CCRenderBuffer buffer, int index, GLushort a, GLushort b, GLushort c) {};

@interface CCRenderer : NSObject
-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
@end

@interface CCSpriteFrame : NSObject
@property (nonatomic) CGPoint offset;
@property (nonatomic) CCTexture *texture;
@end

@interface NSValue (HGCocos2D)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector;

@end

#endif // __has_include
#endif // __has_include