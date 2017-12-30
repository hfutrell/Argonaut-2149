//
//  Texture.h
//  Game Engine
//
//  Created by Holmes Futrell on Fri Apr 04 2003.
//  Copyright (c) 2003 Holmes Futrell. All rights reserved.
//

//Last modified December 11th, 2003.

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>

//enable ARB for multitexturing purposes
#define __ARB_ENABLE TRUE

//The GLTexture class creates individual texture objects.
//I made this class because frankly, I like the objective
//way of doing things.  There are two main ways of creating
//textures.  Use the convenience method initWithResource to
//create a texture from any file format NSImage supports.
//Alpha is not supported by this however.  To use alpha, create
//a .tga file and use initWithTGAResource instead.  To use
//a file path rather than a resource you can use initWithFile
//and initWithTGA.

@interface GLTexture : NSObject {

    GLuint texture; 	//Storage for 1 texture
    GLenum texFormat;   // Format of texture (GL_RGB or GL_RGBA)
    NSSize texSize;     // Width and height
    GLubyte *texBytes;     // Texture data
    NSString *name;
}

+(id)initWithFile:(NSString *)filename;
+(id)initWithTGA:(NSURL *)filename;

+(id)initWithResource:(NSString *)resourceName;
+(id)initWithTGAResource:(NSString *)resourceName;

-(BOOL)loadNSImage:(NSString *)filename;
-(BOOL)loadTGA:(NSString *)filename;
-(void)bind;
//-(void)failure:(NSString *)message;

//-(void)setStartVertex:(int)newStart;
//-(void)setEndVertex:(int)newEnd;
-(void)bindToTexelUnit:(int)unit;

//enable or disable spheremapping
+(void)setSphereMapping:(BOOL)newState;

//-(NSImage *)image;
+(id)initWithOpenPanel;

-(unsigned int)imageHeight;
-(unsigned int)imageWidth;
-(NSSize)size;
//-(char *)texBytes;

-(int)alphaAtPoint:(NSPoint)point;

-(id)emptyTextureWithSize:(NSSize)size;
-(id)grabScreenBuffer;
-(id)renderToTextureWithView:(id)view
    selector:(SEL)selector
    target:(id)target;

//toggling mipmapping
+(void)enableMipMapping;
+(void)disableMipMapping;
+(BOOL)isMipMapping;
+(void)setMipMapping:(BOOL)_state;
-(BOOL)loadTGA:(NSString *)filename nearFilter:(GLenum)nearFilter farFilter:(GLenum)farFilter mipMapping:(BOOL)mipMapping;
+(void)setActiveTextureARB:(int)unit;

@end
