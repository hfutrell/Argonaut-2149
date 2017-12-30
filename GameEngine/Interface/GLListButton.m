//
//  GLListButton.m
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLListButton.h"

@implementation GLListButton

-(BOOL)isSelected {
    return selected;
}

-(void)display {

    [super display];
    
    NSPoint mouseLoc = [self currentMousePosition];

    //if (state==DISABLED){
    //    NSLog(@"Wow, disabled :(");
    //}
    
    //If the button is doin nothing and the mouse is over, then set state to rolloever
    if ( [self pointInBounds: mouseLoc]) {
        if (state==UP){
            state = OVER;
        }
    }
    else {
        if (state==OVER){
            state = UP;
        }
    }

}

-(void)setSelected:(BOOL)_selected {

    //if (selected == _selected) return;
    
    selected=_selected;
    
    if (selected){
        state=DOWN;
        if (action && target) [target performSelector: action];  
    }
    else {
        state=UP;
        //if (![self enabled]) state = DISABLED;
    }
}

- (void)enable {
    //state should not be up because they can be selected when enabled, their matrix will set their state.
    //in other words, don't do anything here!
}

//mouse button is released.  The button recieves this command through notifications.
- (void)mouseUp:(NSEvent *)theEvent
{

}

-(void)mouseDown:(NSEvent *)theEvent
{
      if ([self shouldDisplay] && ![self isZooming]){

        [self retain]; 
    
        //if the mouse down was in the button, the button is not selected, the state is not disabled, and the button has a parent!
        if ( [self pointInBounds: [self currentMousePosition]] && ![self isSelected] && state != DISABLED && parent) {
            [parent setSelectedCell: self];
        }
        
        [self release];
    
    }
}

@end
