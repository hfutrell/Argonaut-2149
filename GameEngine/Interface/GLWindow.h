//
//  GLWindow.h
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLInterfaceObject.h"

//simple winodws are just single graphics
#define TYPE_SIMPLE 0

//complex windows are many graphics put together
//They are capable of scaling to any rect
#define TYPE_COMPLEX 1

@interface GLWindow : GLInterfaceObject {

    GLSprite *sprite;
    int type;
    
    NSPoint destOrigin; //if the window is moving somewhere (outside user control) this is where it's going
    float ZOOMSPEED,zoomAcceleration;
    BOOL hideOnArrival;
    
    NSRect newFrame,oldFrame;
    float resizeTime;
    float elapsedResizeTime;
    BOOL isResizing, displayContentsWhileResizing, shouldDisplayWhenDoneResizing;
}

//initializes a simple window with the graphic sprite
-(id)initWithFrame:(NSRect)_rect
    sprite:(GLSprite *)_sprite;
-(void)setSprite:(GLSprite *)_sprite;
-(void)zoomToPoint:(NSPoint)_destOrigin;
-(void)setZoomSpeed:(float)_zoomAcceleration;
-(void)zoomToPointAndHide:(NSPoint)_destOrigin;
-(void)center:(NSPoint)size;

- (BOOL)isResizing;
- (void)animateToFrame:(NSRect)frameRect displayContents:(BOOL)displayFlag hideWhenFinished:(BOOL)hideWhenDone;
- (void)setResizeTime:(int)time;
@end
