//
//  GLButton.h
//  Argonaut
//
//  Created by Holmes Futrell on Wed Jul 16 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>
#import <Carbon/carbon.h>
#import "GLInterfaceObject.h"

#define UP 0
#define DOWN 1
#define OVER 2
#define DISABLED 3

@interface GLButton : GLInterfaceObject {

    GLSprite *sprite;
    float corner[4][2];
    
    id target; //where we send the action to
    SEL action,enterSelector,exitSelector;
    
    int state; //uses the macros defined above
    int frameToDraw; //based on state, but restricts to frames that exist
    NSOpenGLView *myView; //where we get the events from
    
    NSString *titleText;
    GLFont *font;
    
    char keyEquivalent;
    
    //BOOL allowsDisable;
    
}

-(void)setTitleText:(NSString *)text font:(GLFont *)_font;
-(void)setTitleText:(NSString *)text;

-(id)initWithSprite:(GLSprite *)_sprite
    rect:(NSRect)rect
    action:(SEL)selector
    target:(id)newTarget
    view:(NSOpenGLView *)view;

//disabling and enabling the button
-(void)disable;
-(void)enable;

-(id)setCoordMode:(NSString *)newMode;
-(BOOL)pointInBounds:(NSPoint)point;
-(NSPoint)currentMousePosition;

-(void)setTitleText:(NSString *)text font:(GLFont *)_font;
-(void)setTitleText:(NSString *)text;
-(NSString *)titleText;
- (void)keyDown:(NSNotification *)theNotification;

//key equivilants
-(void)setKeyEquivalent:(unichar)theKey;
-(void)buttonClicked;

@end
