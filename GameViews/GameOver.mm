//
//  GameOver.m
//  Asterex
//
//  Created by Holmes Futrell on Tue Aug 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GameOver.h"


@implementation GameOver

-(id)init {
        
    self = [super init];
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"Loading Items" object: [NSNumber numberWithInt: 2]];

    bigFont = [GLFont initWithResource:@"data/fonts/bigfont.tga" xSpacing: 32 ySpacing: 32];
    littleFont = [GLFont initWithResource:@"data/fonts/font.tga" xSpacing: 16 ySpacing: 16];


    gameOverField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,100,800,0)
                                    font: bigFont
                                    string:@"Game Over"];
                                    
    [gameOverField alignCenter];
                                    
    didQualifyField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,132,800,0)
                                    font: littleFont
                                    string:@"You've qualified for a high score!"];
                        
    [didQualifyField alignCenter];
                        
    nameField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,164,800,0)
                                    font: bigFont
                                    string:@"Anonymous"];
                                    
    [nameField alignCenter];
    [nameField setEditable: YES];
    [nameField setMaxLength: 30];
    
    [self setNextResponder: nameField];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Loading Complete" object: self];
        
    return self;

}

-(void)make {

    [gameOverField display];
    [didQualifyField display];
    [nameField display];
    
}

/*
 * Handle key presses
 */
//- (void) keyDown:(NSEvent *)theEvent
//{ 
    //[[GameView SharedInstance] transitionBetween: self to: [Menu alloc]];

//}  

-(void)dealloc {

    [littleFont release];
    [bigFont release];
    [gameOverField release];
    [didQualifyField release];
    [nameField release];

}

@end
