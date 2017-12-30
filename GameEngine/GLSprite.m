//
//  GLSprite.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 13 2003.
//  Copyright (c) 2003. All rights reserved.
//

#import "GLSprite.h"

@implementation GLSprite

-(id)init {

    self = [super init];
    framesArray = [[NSMutableArray alloc] init];
    return self;
    
}

-(id)initWithImages:(NSString *)stem extension:(NSString *)extension frames:(int)frames {

    int n;
    
    self = [self init];
    
    for (n=1;n<=frames;n++){
    
        NSString *fileName = [NSString stringWithFormat:@"%@%d%@",stem,n,extension];
        
        GLTexture *newFrame;
        
        [GLTexture disableMipMapping];
        
        if ([extension isEqual:@".tga"] || [extension isEqual:@".TGA"]) {
            newFrame = [GLTexture initWithTGAResource: fileName];
        }
        else {
            newFrame = [GLTexture initWithResource: fileName];
        }
        
        [GLTexture enableMipMapping];

        [framesArray addObject: newFrame];
        radius = sqrt( pow([newFrame imageWidth] / 2.0,2)+pow([newFrame imageHeight] / 2.0,2));
    
		[newFrame release];
	
    }
    [self setCoordMode:@"left corner"];
        
    return self;

}

-(void)dealloc {

    [framesArray release];
    [super dealloc];

}

-(id)initWithSingleImage:(NSString *)filename extension:(NSString *)extension {

    self = [self init];
        
    NSString *fileName = [NSString stringWithFormat:@"%@%@",filename,extension];
        
    GLTexture *newFrame;
        
    [GLTexture disableMipMapping];
    
    if ([extension isEqual:@".tga"]) {

        newFrame = [GLTexture initWithTGAResource: fileName];

    }
    else {
            
        newFrame = [GLTexture initWithResource: fileName];
            
    }
    
    [GLTexture enableMipMapping];
        
    [framesArray addObject: newFrame];
    [newFrame release];
	
    [self setCoordMode:@"left corner"];
    
    radius = sqrt( pow([newFrame imageWidth] / 2.0,2)+pow([newFrame imageHeight] / 2.0,2));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Item Loaded" object: self];
    
    return self;

}

//draws the first frame of the sprite, convenient if sprite only has one frame
-(void)draw {

    [self drawFrame: 0];

}

//draws a specified frame of the sprite
-(void)drawFrame:(int)frame {

    GLTexture *image = [framesArray objectAtIndex: frame];
    
    //glPushAttrib(GL_LIGHTING | GL_TEXTURE_2D | GL_CULL_FACE);
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
        
    [image bind];
    
    glBegin(GL_QUADS);
        
        glTexCoord2d(0.0,1.0);
        glVertex2fv(corner[0]);
        glTexCoord2d(1.0,1.0);
        glVertex2fv(corner[1]);
        glTexCoord2d(1.0,0.0);
        glVertex2fv(corner[2]);
        glTexCoord2d(0.0,0.0);
        glVertex2fv(corner[3]);
    
    glEnd();
    
    //glPopAttrib();

}

//adds a frame to the array of frames (on the end)
-(void)addFrame:(GLTexture *)newFrame {

    [framesArray addObject: newFrame];

}

-(void)drawFrame:(int)frame size:(NSSize)size {

    GLTexture *image = [framesArray objectAtIndex: frame];
	[image bind];
	
	glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
		
    glBegin(GL_QUADS);
        
        glTexCoord2d(0.0,1.0);
        glVertex2f(0,0);
        glTexCoord2d(1.0,1.0);
        glVertex2f(size.width,0.0);
        glTexCoord2d(1.0,0.0);
        glVertex2f(size.width,size.height);
        glTexCoord2d(0.0,0.0);
        glVertex2f(0.0f,size.height);
    
    glEnd();

}

-(id)setCoordMode:(NSString *)newMode {

    GLTexture *image;
    image = [framesArray objectAtIndex: 0];

    if ([newMode isEqual:@"center"]){
    
        corner[0][0]= -(float)[image imageWidth]/2.0f;
        corner[0][1]= -(float)[image imageHeight]/2.0f;
        corner[1][0]= (float)[image imageWidth]/2.0f;
        corner[1][1]= -(float)[image imageHeight]/2.0f;
        corner[2][0]= (float)[image imageWidth]/2.0f;
        corner[2][1]= (float)[image imageHeight]/2.0f;
        corner[3][0]= -(float)[image imageWidth]/2.0f;
        corner[3][1]= (float)[image imageHeight]/2.0f;
        return self;
    }
    else if ([newMode isEqual:@"left corner"]) {
        corner[0][0]= 0.0;
        corner[0][1]= 0.0;
        corner[1][0]= [image imageWidth];
        corner[1][1]= 0.0;
        corner[2][0]= [image imageWidth];
        corner[2][1]= [image imageHeight];
        corner[3][0]= 0.0;
        corner[3][1]= [image imageHeight];
        return self;
    }
    NSLog(@"Error, invalid coordinate mode!");
    return self;
}

//Backgrounds MUST be drawn first because they clear the depth buffer
-(void)drawFrameAsBackground:(int)frame {
    
    GLTexture *image = [framesArray objectAtIndex: frame];
    
    //glPushAttrib(GL_LIGHTING | GL_TEXTURE_2D | GL_CULL_FACE);
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
    
    [image bind];
	
	float p1 = 0.78125, p2 = 0.5859375;
	
    glPushMatrix();
    
        glLoadIdentity();
        
        glTranslatef(0.0,0.0,-999.0);
        
        glBegin(GL_QUADS);
            
            glTexCoord2f(0.0,1.0);
            glVertex2d(0.0,0.0);
            
			glTexCoord2f(p1,1.0);
            glVertex2d(800,0.0);
            
			glTexCoord2f(p1,1.0 - p2);
            glVertex2d(800,600);
            
			glTexCoord2f(0.0,1.0 - p2);
            glVertex2d(0.0,600);
        
        glEnd();
            
    glPopMatrix();
    
    //glPopAttrib();

}

-(float)radius {

    return radius;

}

//returns the number of frames in the sprite
-(unsigned int)numFrames {

    return [framesArray count];

}

//returns a frame specified by number from the frames array of the sprite
-(GLTexture *)frameNumber:(int)number {

    return (GLTexture *)[framesArray objectAtIndex: number];

}

-(NSString *)description {
 
    //NSMutableString *description= [[[NSMutableString alloc] init] autorelease];
        NSMutableString *description= [[NSMutableString alloc] init];

    [description setString: [NSString stringWithFormat:@"Sprite Object, frames %d",[framesArray count]] ];
    
    int i;
    for (i=0;i<[framesArray count];i++){
     
        [description appendString:[NSString stringWithFormat:@"\n%@",[[framesArray objectAtIndex:i] description]]];
        
    }
    return description;
    
}

@end
