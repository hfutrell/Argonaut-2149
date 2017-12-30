//
//  GLInterfaceObject.m
//  Argonaut
//
//  Created by Holmes on Sat Aug 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLInterfaceObject.h"
#import "PreferenceController.h"

@interface GLInterfaceObject (InternalMethods)
@end

@implementation GLInterfaceObject

-(void)translate {

    if (parent){ 
        [parent translate];
    }
    glTranslatef(frame.origin.x,frame.origin.y,0.0);

}

-(void)setShouldDisplay:(BOOL)state{
    shouldDisplay = state;
}

-(BOOL)shouldDisplay {
    //search up the parent tree, if anyone above you isn't displaying, neither should you
    if (!shouldDisplay) return FALSE;
    return parent ? [parent shouldDisplay] : TRUE;
}

-(BOOL)isZooming {
    return parent ? [parent isZooming] : isZooming;
}

-(id)init {
    if (self = [super init]) {
        shouldDisplay = YES;
        enabled=YES;
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

-(float)timeSinceLastRender{
    return timeSinceLastRender;
}

-(void)setTimeSinceLastRender {

    long milliseconds;
    struct timeval rightNow;

    gettimeofday( &rightNow, NULL );
    milliseconds = ( rightNow.tv_sec - lastTime.tv_sec ) * 1000;
    milliseconds += ( rightNow.tv_usec - lastTime.tv_usec ) / 1000;
    lastTime = rightNow;

    float frameTime = milliseconds / 16.667;
    if (frameTime > 0 && frameTime < 5.0) {
        timeSinceLastRender = frameTime;
    }

}

-(id)parent {
    return parent;
}

-(void)setParent:(id)_parent {
    parent = _parent;
}
-(void)addChild:(id)child {
    [child setParent: self];
    [children addObject: child];
}

-(void)removeChild:(id)child {

    NSLog(@"warning, this is unimplimented");
    //Unimplimented

}

-(void)disable {
    int i;
    for (i=0;i<[children count];i++){
        [[children objectAtIndex: i] disable];
    }
    enabled=NO;
}

//THIS SHOULD LOOK UP PARENTS TOO
-(BOOL)enabled {
    return enabled;
}

-(void)enable {
    int i;
    for (i=0;i<[children count];i++){
        [[children objectAtIndex: i] enable];
    }
    enabled=YES;
}

-(void)removeAllChildren {
 
    [children removeAllObjects];
    
}
-(void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self removeAllChildren];
    [children release];
#warning this super dealloc call is needed, but for some reason it makes the game crash after the loading screen is over. So temporarily disabled.
//    [super dealloc];

}

-(void)setFrame:(NSRect)_rect {

    frame = _rect;

}
-(NSArray *)children {

    return children;

}

-(void)display {

    //draw the objects children
    int i;
    for (i=0;i<[children count];i++){
    
        if ([self clipToFrame]){
    
            //note, this should use absolute frame
            glEnable(GL_SCISSOR_TEST);
            glScissor([self absoluteFrame].origin.x, verticalResolution-[self absoluteFrame].origin.y-[self absoluteFrame].size.height, [self absoluteFrame].size.width, [self absoluteFrame].size.height);
            
        }
    
        id child = [children objectAtIndex: i];
        [child display];
    }
    
    glDisable(GL_SCISSOR_TEST);
    
}

//sets the objects tag (for identification)
-(void)setTag:(int)_tag{
    tag=_tag;
}

//returns the objects tag
-(int)tag {
    return tag;
}

-(void)setClipToFrame:(BOOL)aState {
    clipToFrame = aState;
}
-(BOOL)clipToFrame{
    return clipToFrame;
}

/*this function will cycle up the parent tree to figure out where the object is not relative to its parents, but to the root coordinate system. */
-(NSPoint)absolutePosition {

    NSPoint absolutePosition = NSMakePoint(0,0);
    if (parent){
    
        NSPoint parentPosition = [parent absolutePosition];
        absolutePosition.x += parentPosition.x;
        absolutePosition.y += parentPosition.y;
    
    }
    absolutePosition.x += [self frame].origin.x;
    absolutePosition.y += [self frame].origin.y;
    return absolutePosition;

}

//frame relative to main window, not to parent
-(NSRect)absoluteFrame {
    
    return NSMakeRect([self absolutePosition].x,[self absolutePosition].y,[self frame].size.width,[self frame].size.height);
    
}

-(NSRect)frame {

    return frame;
    
}


@end
