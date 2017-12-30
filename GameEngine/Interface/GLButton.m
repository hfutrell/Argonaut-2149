//
//  GLButton.m
//  Argonaut
//
//  Created by Holmes Futrell on Wed Jul 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLButton.h"

@implementation GLButton

//IMPORTANT NOTE: all button images should be the same size!

//Send the texture images
//The coordinates
//The action you want the button to do
//And the target

-(void)setTitleText:(NSString *)text font:(GLFont *)_font {

    if (titleText) [titleText release];
    titleText = [text retain];
    if (font) [font release];
    font = [_font retain];

}

//returns the buttons title text
-(NSString *)titleText{
    return titleText;
}

-(void)buttonClicked {

}

-(void)setTitleText:(NSString *)text {

    if(titleText) [titleText release];
    titleText = text;
    
}

-(id)initWithSprite:(GLSprite *)_sprite
        rect:(NSRect)rect
        action:(SEL)selector
        target:(id)newTarget
        view:(NSOpenGLView *)view {
    
    self = [self init];
    
    sprite = [_sprite retain];
    myView = view;
    action = selector;
    target = newTarget;
    [self setFrame: rect];
    state = UP;
    //allowsDisable = YES;
    
    //[self addTrackingRect: bounds owner:self userData: nil assumeInside: YES];
    [self setCoordMode:@"left corner"];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(mouseDown:)
        name:@"MouseDown" object: nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(mouseUp:)
        name:@"MouseUp" object: nil];
    return self;
    
}

-(id)init {
    self = [super init];
    //allowsDisable = YES;
    return self;
}

- (void) disable {
    //if (allowsDisable){
        state = DISABLED;
        [super disable];
    //}
}

- (void)enable {
    //if (allowsDisable){
        state = UP;
        [super enable];
    //}
}

- ( void ) display {
        
    glPushMatrix();
    /*
    if (![sprite frameNumber: state]){
        NSLog(@"ERROR: Button image non-existant.");
        return;
    }
    if ([[sprite frameNumber: state] imageWidth] < 1 || [[sprite frameNumber: state] imageHeight] < 1){
        NSLog(@"ERROR: INVALID IMAGE DIMENSIONS");
        return;
    } */
    glPushMatrix();
        glLoadIdentity();
        [self translate];
        glColor4f(1.0f,1.0f,1.0f,1.0f);
        frameToDraw = ([sprite numFrames] > state) ? state : 0;//just draw the first frame if we don't have a frame for buttons state
        if ([sprite numFrames]) [sprite drawFrame: frameToDraw];
    glPopMatrix();
    
    //handle the title text of the button
    if (titleText && font){ //does the button have a title and a font?
    
        NSPoint stateOffset; //the offset of the title text due to the buttons state
        switch(state){//it is not based on frame to draw, because we want the text to be able to be disabled even when the button can't look disabled
            case UP:
                stateOffset.x = 0;
                stateOffset.y = 0;
                break;
            case DOWN: //if the button is down, offset the text a bit
                stateOffset.x = 1;
                stateOffset.y = 1;
                break;
            case OVER:
                //if (sprite){
                    stateOffset.x = 0; //don't do nothing
                    stateOffset.y = 0;
                //}
                //else {
                //    stateOffset.x = -10; //don't do nothing
                //    stateOffset.y = -10;   
                //}
                break;
            case DISABLED:
                glColor4f(1.0f,1.0f,1.0f,0.3f); //if the button is disabled change the text color
                stateOffset.x = 0;
                stateOffset.y = 0;
                break;
        }
        NSPoint buttonOffset; //the offset created by the button itself
        if (sprite){
            buttonOffset.x = 10;
            buttonOffset.y = ([[sprite frameNumber: frameToDraw] imageHeight]-[font ySpacing])/2.0;
        }
        [font printAtX: [self absolutePosition].x+buttonOffset.x+stateOffset.x y: [self absolutePosition].y+buttonOffset.y+stateOffset.y string:[titleText cString]];
        glColor4f(1,1,1,1);
    }
    
    glPopMatrix();
}

-(id)setCoordMode:(NSString *)newMode {

   [sprite setCoordMode:(NSString *)newMode];
   return self;
   
}

//check if a point is in the button and the button is not 100% transparent at that point.
-(BOOL)pointInBounds:(NSPoint)point {

    if (sprite){
    
        NSPoint relativePoint; //the point in the objects bitmap coordinate system (the pixel coordinates)
        NSPoint absolutePosition = [self absolutePosition];
        relativePoint.x = (-(absolutePosition.x+sprite->corner[0][0])+point.x);
        relativePoint.y = (-(absolutePosition.y+sprite->corner[0][1])+point.y);
        if ([[sprite frameNumber:frameToDraw] alphaAtPoint: relativePoint]) return TRUE;
    
    }
    else {
        if (NSPointInRect(point,[self absoluteFrame])){
            return TRUE;
        }
    }
    
    return FALSE;

}

-(void)dealloc {

    //[[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    if (sprite) [sprite release];
    [font release];
    [titleText release];
    [super dealloc];
}

- (NSPoint) currentMousePosition
{
    NSPoint mouseLoc =   [[ myView window ] convertScreenToBase:[ NSEvent mouseLocation ] ];
    mouseLoc.y = [ myView bounds ].size.height - mouseLoc.y;
    return mouseLoc;
}

//here are some common key equiv's
//27 = escape
//13 = return
//0 = NSUpArrowFunctionKey = up arrow
//1 = NSDownArrowFunctionKey = up arrow
//2 = NSLeftArrowFunctionKey = up arrow
//3 = NSRightArrowFunctionKey = up arrow
//9 = tab
//127 = delete
//32 = space

-(void)setKeyEquivalent:(unichar)theKey{
    keyEquivalent = theKey;
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(keyDown:)
            name:@"KeyDown" object: nil];
}

- (void) keyDown:(NSNotification *)theNotification {

    NSEvent *theEvent = [theNotification object];

     if ([self shouldDisplay] && ![self isZooming]){

        char unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
        
        //NSLog(@"keyEquiv = %d",unicodeKey);
        
        if ( unicodeKey==keyEquivalent )
        {
            [self retain];
            [self buttonClicked];
            [self release];
        }
    
    }
}


@end