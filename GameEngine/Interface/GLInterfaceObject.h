//
//  GLInterfaceObject.h
//  Argonaut
//
//  Created by Holmes on Sat Aug 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLSprite.h>
#import "GLTexture.h"
#import "GLFont.h"
#import <sys/time.h>

@interface GLInterfaceObject : NSResponder {

    NSRect frame;
    id parent;
    BOOL shouldDisplay, clipToFrame;
    NSMutableArray *children;
    int tag;
    
    BOOL isZooming; //is the window moving somewhere?
    BOOL enabled;//is the interface object enabled
    
    //for computing time since last render
    struct timeval lastTime;
    float timeSinceLastRender;

}

-(void)disable;
-(void)enable;
-(BOOL)enabled;

-(id)parent; //returns the parent of the object (the object that the object is attached to)
-(void)setParent:(id)parent; //sets the parent of the object
-(void)addChild:(id)child; //adds a child to the object (this object will move with it)
-(void)removeChild:(id)child; //removes a child (unimplimented)
-(void)setFrame:(NSRect)rect; //sets the objects rect
-(NSArray *)children; //returns an array of the objects children
-(void)display; //draws the object on the screen
-(NSPoint)absolutePosition; //return the objects position in the OpenGLViews coordinate system
-(NSRect)frame; //returns the rect of the object
-(NSRect)absoluteFrame;
-(void)translate; //translates the object to its absolute position
-(void)setShouldDisplay:(BOOL)state;//if this is NO, the object won't draw, nor its children
-(BOOL)shouldDisplay;
-(void)setTag:(int)_tag; //sets the tag
-(int)tag; //returns the tag

//returns the time since last rendered.  *note:  this will only be accurate if the class itself impliments it.
-(float)timeSinceLastRender;
-(void)setTimeSinceLastRender;
-(BOOL)isZooming;

//if an object has clip to frame on, its childrens graphics will not be drawn outside its frame.
-(void)setClipToFrame:(BOOL)aState;
-(BOOL)clipToFrame;
-(void)removeAllChildren ;

@end
