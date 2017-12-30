//
//  Particle.m
//  Asterex
//
//  Created by Holmes Futrell on Sun Jul 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpaceDust.h"

static NSMutableSet *sharedSet;
static GLSprite *starSprite;

@implementation SpaceDust

+(id)sharedSet {
    return !sharedSet ? sharedSet = [NSMutableSet new] : sharedSet;
}

+(void)initAssets {
    starSprite = [[GLSprite alloc] loadSingleFrame:@"data/sprites/star" extension:@".jpg"];
}

+(void)deallocAssets {

    [starSprite release];
    [sharedSet removeAllObjects];
    
}

+(void)makeAll {

    glDisable(GL_DEPTH_TEST);

    glPushMatrix();
    
    glPushAttrib(GL_LIGHTING);

    glDisable(GL_LIGHTING);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE);  

    [[SpaceDust sharedSet] makeObjectsPerformSelector:@selector(make) withObject: nil];
    
    glPopAttrib();
    
    glPopMatrix();
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    
    glEnable(GL_DEPTH_TEST);

}
    
+(id)spawn {

    SpaceDust *newDust = [SpaceDust new];
    newDust->pos[0]=cameraPos[0]+[Randomness complex: 0 max: 800]-400;
    newDust->pos[1]=cameraPos[1]+[Randomness complex: 0 max: 600]-300;
    [[SpaceDust sharedSet] addObject: [newDust autorelease]];
    newDust->maxspeed = 0;
    return newDust;
}

-(void)make {

    if (![self isOnScreen]){
        [self setCoordsViewingEdge];
    }

    pos[0] += vel[0] * FRAME;
    pos[1] += vel[1] * FRAME;
    
    //glEnable(GL_POINT_SMOOTH);
    glPointSize(2);
    glColor4f(1.0,1.0,1.0,1.0);
    glPushMatrix();
        glTranslatef(pos[0],pos[1],-300);
        [starSprite draw];
    glPopMatrix();
}

@end
