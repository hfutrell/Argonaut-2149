//
//  GLWindow.m
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLWindow.h"

@implementation GLWindow

-(id)initWithFrame:(NSRect)_rect
    sprite:(GLSprite *)_sprite {
    
    self = [super init];
    
	sprite = [_sprite retain];
	
    [self setFrame: _rect];
    
    switch ([sprite numFrames]) {
        case 1:
            type = TYPE_SIMPLE;
            break;
        case 9:
            type = TYPE_COMPLEX;
            break;
        default:
            NSLog(@"Invalid window sprite");
            break;
    }
    
    resizeTime = 10;
    zoomAcceleration = 8;
    
    return self;
}

/*
-(id)initWithTexture:(GLTexture*)_texture rect:(NSRect)_rect {

    [super init];
    [self setTexture: _texture];
    [self setRect: _rect];
    type = TYPE_SIMPLE_STRETCH;
    return self;


} */

-(void)setSprite:(GLSprite *)_sprite {
	if (sprite) [sprite release];
    sprite = [_sprite retain];
}

-(void)dealloc {

    [sprite release];
    [super dealloc];
    
}

-(void)center:(NSPoint)size {
    frame.origin.x = (int)((size.x - frame.size.width)/2.0);
    frame.origin.y = (int)((size.y - frame.size.height)/2.0);
    
}

-(void)display {

    int wh;
    int ww;
    int verticalStretch;
    int horizontalStretch;

    if (![self shouldDisplay]) return;
    
    glPushMatrix();

    [self setTimeSinceLastRender];

    if (isResizing){
        
        elapsedResizeTime +=[self timeSinceLastRender];
        float percentDone = (elapsedResizeTime / resizeTime);
        float tempx     = (int)((oldFrame.origin.x * (1.0f-percentDone)) + (newFrame.origin.x * percentDone));
        float tempy     = (int)((oldFrame.origin.y * (1.0f-percentDone)) + (newFrame.origin.y * percentDone));
        float tempxsize = (oldFrame.size.width * (1.0f-percentDone)) + (newFrame.size.width * percentDone);
        float tempysize = (oldFrame.size.height * (1.0f-percentDone)) + (newFrame.size.height * percentDone);
        [self setFrame: NSMakeRect(tempx,tempy,tempxsize,tempysize)];

        if (elapsedResizeTime >= resizeTime){
            isResizing = NO;
            [self setFrame: newFrame];
            if (!shouldDisplayWhenDoneResizing){
                [self setShouldDisplay: NO];
            }
        }
    }
    
    if (isZooming){
        float angle = atan2( [self frame].origin.y - destOrigin.y , [self frame].origin.x - destOrigin.x );
        frame.origin.x -= cos(angle) *ZOOMSPEED * [self timeSinceLastRender];
        frame.origin.y -= sin(angle) *ZOOMSPEED * [self timeSinceLastRender];
        ZOOMSPEED+=zoomAcceleration*[self timeSinceLastRender];
        if ([self frame].origin.y > destOrigin.y-ZOOMSPEED*[self timeSinceLastRender] && [self frame].origin.y < destOrigin.y+ZOOMSPEED*[self timeSinceLastRender] && [self frame].origin.x > destOrigin.x-ZOOMSPEED*[self timeSinceLastRender] && [self frame].origin.x < destOrigin.x+ZOOMSPEED*[self timeSinceLastRender]){
            frame.origin = destOrigin;
            isZooming = NO; //the window arrived at its destination
            ZOOMSPEED=0;
            if (hideOnArrival) [self setShouldDisplay: NO];
        }
    }
        
    [self translate];
    
    switch (type) {
        case TYPE_SIMPLE:
            [sprite draw];
            break;
        case TYPE_COMPLEX:
            //draw top left corner
            
            wh = (int)frame.size.height;
            ww = (int)frame.size.width;
            verticalStretch = wh - [[sprite frameNumber: 0] imageHeight] - [[sprite frameNumber: 6] imageHeight];
            horizontalStretch = ww - [[sprite frameNumber: 0] imageWidth] - [[sprite frameNumber: 2] imageWidth];
            
            if (verticalStretch < 0 || horizontalStretch < 0){
                glPopMatrix();//pop the matrix back to avoid screwin' it all up!
                return;//don't bother drawing
            }
            
            [sprite drawFrame: 0];
            
            //upper middle
            glPushMatrix();
                glTranslatef([[sprite frameNumber: 0] imageWidth],0,0);
                [sprite drawFrame: 1 size: NSMakeSize(horizontalStretch,[[sprite frameNumber: 1] imageHeight])];
            glPopMatrix();
            
            //upper right
            glPushMatrix();
                glTranslatef(ww - [[sprite frameNumber: 2] imageWidth],0,0);
                [sprite drawFrame: 2];
            glPopMatrix();
            
            //middle-left
            glPushMatrix();
                glTranslatef(0,[[sprite frameNumber: 3] imageHeight],0);
                [sprite drawFrame: 3 size: NSMakeSize([[sprite frameNumber: 3] imageWidth],verticalStretch)];
            glPopMatrix();
            
            //middle-middle
            glPushMatrix();
                glTranslatef([[sprite frameNumber: 0] imageWidth],[[sprite frameNumber: 0] imageHeight],0);
                [sprite drawFrame: 4 size: NSMakeSize(horizontalStretch,verticalStretch)];
            glPopMatrix();
            
            //middle-right
            glPushMatrix();
                glTranslatef(ww - [[sprite frameNumber: 5] imageWidth],[[sprite frameNumber: 0] imageHeight],0);
                [sprite drawFrame: 5 size: NSMakeSize([[sprite frameNumber: 5] imageWidth],verticalStretch)];
            glPopMatrix();
            
            //lower-left
            glPushMatrix();
                glTranslatef(0.0,wh - [[sprite frameNumber: 6] imageHeight],0);
                [sprite drawFrame: 6];
            glPopMatrix();
            
            //lower-middle
            glPushMatrix();
                glTranslatef([[sprite frameNumber: 6] imageWidth],wh - [[sprite frameNumber: 6] imageHeight],0);
                [sprite drawFrame: 7 size:NSMakeSize(horizontalStretch,[[sprite frameNumber: 7] imageHeight])];
            glPopMatrix();
            
            //lower-right
            glPushMatrix();
                glTranslatef(ww - [[sprite frameNumber: 8] imageWidth],wh - [[sprite frameNumber: 8] imageHeight],0);
                [sprite drawFrame: 8];
            glPopMatrix();
            
        break;
    }
    
    glPopMatrix();
    
    //this will draw the windows children
    if (!(isResizing && !displayContentsWhileResizing)){
        [super display];
    }

}

-(void)setZoomSpeed:(float)_zoomAcceleration{
    zoomAcceleration = _zoomAcceleration;
}

-(void)zoomToPoint:(NSPoint)_destOrigin {

    [self setShouldDisplay: YES];
    destOrigin = _destOrigin;
    isZooming = YES;
    hideOnArrival = NO;


}

-(void)zoomToPointAndHide:(NSPoint)_destOrigin {

    destOrigin = _destOrigin;
    isZooming = YES;
    hideOnArrival = YES;

}

- (void)animateToFrame:(NSRect)frameRect displayContents:(BOOL)displayFlag hideWhenFinished:(BOOL)hideWhenDone {
    isResizing = YES;
    newFrame = NSMakeRect((int)frameRect.origin.x,(int)frameRect.origin.y,(int)frameRect.size.width,(int)frameRect.size.height);
    oldFrame = [self frame];
    displayContentsWhileResizing = displayFlag;
    shouldDisplayWhenDoneResizing = !hideWhenDone;
    elapsedResizeTime = 0;
}

-(BOOL)isResizing {
    return isResizing;
}

- (void)setResizeTime:(int)time {
    resizeTime = time;
}


@end
