//
//  GLPushButton.m
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLPushButton.h"

@implementation GLPushButton

-(void)display {

    [self handleMouseMove];
    [super display];

}

//mouse button is released.  The button recieves this command through notifications.
- (void)mouseUp:(NSEvent *)theEvent
{

    if ([self shouldDisplay] && ![self isZooming]){

        [self retain]; 
        
        //its possible that the buttons action will indirectly deallocate itself
        //we retain itself to avoid crashing if this happens, then release it when the method is done.
    
        //only perform the action if the mouse is still in bounds (use can cancel)
        if (state == DOWN ) {
            state = UP; 
            if ( [self pointInBounds: [ self currentMousePosition ]] && action && target){
                [self buttonClicked];
            }
        }
        
        [self release];
    
    }
}

-(void)buttonClicked {

    if (state != DISABLED) {
		[self retain];
		[target performSelector: action];
		[self release];
	}
}

-(void)mouseDown:(NSEvent *)theEvent
{
      if ([self shouldDisplay] && ![self isZooming]){
        //switch from Cocoa to game coordinate system;
        //Detect collision between mouse and button
        if ( [self pointInBounds: [self currentMousePosition]] ) {
            if (state != DISABLED){
                state = DOWN;
            }
        }
    }
}

/*
- (void) keyDown:(NSEvent *)theEvent {

     if ([self shouldDisplay] && ![self isZooming]){

        unichar unicodeKey;
        unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
        switch( unicodeKey )
        {
            //case NSReturnButton:
            //NSLog(@"Make it so if you're the default you send the action.");
            //break;
        }
    
    }
} */

-(void)handleMouseMove {

    NSPoint mouseLoc = [self currentMousePosition];

    //If the button is doin nothing and the mouse is over, then set state to rolloever
    if ( [self pointInBounds: mouseLoc]) {
        if (state==UP){
            if (enterSelector){ //if the button has something it should do on a rollover, do it now;
                [self performSelector: enterSelector withObject: self];
            }
            state = OVER;
        }
    }
    else { 
        if (state==OVER){
            if (exitSelector){ //if the button has something it should on a rollout, do it now;
                [self performSelector: exitSelector withObject: self];
            }
            state=UP;
        }
        else if (state==DOWN && state != DISABLED){
            state=UP;
        }
    }
}

@end
