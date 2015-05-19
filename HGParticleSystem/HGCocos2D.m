/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "HGCocos2D.h"

#if defined(__has_include)
#if !__has_include("cocos2d.h")

const NSString *CCBlendFuncSrcColor = @"CCBlendFuncSrcColor";
const NSString *CCBlendFuncDstColor = @"CCBlendFuncDstColor";

@implementation CCNode
- (void)removeFromParent {}
- (void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup {}
- (CGPoint)convertToWorldSpace:(CGPoint)point { return point; }
@end

@implementation CCTexture
- (id)initWithCGImage:(CGImageRef)cgImage contentScale:(CGFloat)contentScale { return nil; }
@end

@implementation CCShader
+ (instancetype)positionTextureColorShader { return nil; }
@end

@implementation CCFileUtils
+ (instancetype)sharedFileUtils {
    static CCFileUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSString*) fullPathFromRelativePath:(NSString*) relPath { return relPath; }
-(NSString*) fullPathForFilename:(NSString*)filename { return filename; }
@end

@implementation CCRenderer
- (CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder
{
    CCRenderBuffer b;
    return b;
}
@end

@implementation CCBlendMode
+ (instancetype)premultipliedAlphaMode { return nil; }
+ (instancetype)blendModeWithOptions:(id)options { return nil; }
@end

@implementation NSValue (HGCocos2D)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector { return nil; }

@end

#endif // __has_include
#endif // __has_include