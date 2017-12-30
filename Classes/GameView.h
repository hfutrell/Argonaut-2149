//
//  GameView.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Jun 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#define MODE_PLAYING 0
#define MODE_MAIN_MENU 1

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <GLUT/glut.h>
#import <sys/time.h>

//Some needed functions
#import <Randomness.h>
#import "MacInput.h"

//The game screens
//#import "Menu.h"
//#import "Game.h"
//#import "Level.h"
//#import "Loading.h"
//#import "FrameRate.h"

#import "FocoaMod.h"


@interface GameView : NSOpenGLView {

    int colorBits;
    int depthBits;
    BOOL runningFullScreen;
            
    int GameMode;
    float frameTime;
    
    id renderScreen;
    
}

-(void)transitionBetween:(id)from to:(id)to;

-(BOOL)initGL;
-(void)viewPerspective;

//flushes GL buffer
- (void) flush;
- (void)drawRect:(NSRect)rect;
- (void) view3D;
- (void) view2D;
- (void) viewPixel;
//-(void) view2DWithSize:(NSPoint)size;
- (NSPoint) currentMousePosition;
+ (void)SetFrameMultiply:(float)newFrameMultiply;
+ (float)frameMultiply;
+ (id)SharedInstance;

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
       depthBits:(int)numDepthBits;
- (void)setRenderScreen:(id)newScreen;

@end
