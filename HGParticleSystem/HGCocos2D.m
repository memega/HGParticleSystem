//
//  HGCocos2D.m
//  HGParticleSystem-ios
//
//  Created by Yuriy Panfyorov on 17/08/14.
//  Copyright (c) 2014 Yuriy Panfyorov. All rights reserved.
//

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