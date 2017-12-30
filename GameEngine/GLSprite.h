//
//  GLSprite.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 13 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLTexture.h>

@interface GLSprite : NSObject {

    //this array holds GLTexture objects
    NSMutableArray *framesArray;
    float radius;

    @public
        
        //this is public to reduce accessors to it (it'd require 8!)
        float corner[4][2];
    

}
-(id)initWithImages:(NSString *)stem extension:(NSString *)extension frames:(int)frames;
-(id)initWithSingleImage:(NSString *)filename extension:(NSString *)extension;

-(void)drawFrame:(int)frame;
-(void)draw;
-(void)drawFrameAsBackground:(int)frame;
-(void)drawFrame:(int)frame size:(NSSize)size;
-(id)setCoordMode:(NSString *)newMode;
-(float)radius;
-(unsigned int)numFrames;

-(GLTexture *)frameNumber:(int)number;
-(void)addFrame:(GLTexture *)newFrame;
@end
