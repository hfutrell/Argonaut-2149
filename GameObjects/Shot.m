//
//  Shot.m
//  Argonaut
//
//  Created by Holmes Futrell on Wed Jul 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Shot.h"

#define SHOTSPEED 18
#define SHOTTIME 30

static GLSprite *shotSprite;
static NSMutableArray *sharedSet;

@implementation Shot

+(void)InitAssets {
    shotSprite = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/shot" extension:@".tga"]setCoordMode:@"center"];
}


+(void)deallocAssets {

    [shotSprite release];
    [sharedSet release];
       sharedSet = nil;

}

+(void)setSharedSet:(NSMutableSet *)newSet {
 
    if (sharedSet) [sharedSet release];
    sharedSet = [sharedSet retain];
    
}


+(id)sharedSet {
    return !sharedSet ? sharedSet = [[NSMutableSet alloc] init] : sharedSet;
}

/*+(void)SpawnAtX:(float)x y:(float) y rotation:(float)rotation {
 
    Shot *newShot = [[super init] alloc];
    newShot->pos[0]=x;
    newShot->pos[1]=y;
    newShot->vel[0]= degreeCosine(rotation)*SHOTSPEED;
    newShot->vel[1]= degreeSine(rotation)*SHOTSPEED;
    newShot->time=SHOTTIME;
    newShot->radius = 4.0;
    newShot->inertia = 100.5f;
    newShot->danger = -10.0; //funny, but best to move towards shots so you don't get behind enemy!
        
    [[Shot sharedSet] addObject: newShot];
    
}*/

-(float)radius {
    return 4.0f;
}
-(float)danger {
    return 2.0;
}

+(Shot *)SpawnFrom:(GameObject *)master {

    Shot *newShot = [[Shot alloc] init];
    newShot->pos[0]= master->pos[0]+degreeCosine(master->rot)*[master radius];
    newShot->pos[1]= master->pos[1]+degreeSine(master->rot)*[master radius];
    newShot->vel[0]= degreeCosine(master->rot)*SHOTSPEED+master->vel[0];
    newShot->vel[1]= degreeSine(master->rot)*SHOTSPEED+master->vel[1];
    newShot->rot = master->rot;
    newShot->time= SHOTTIME;
    //newShot->radius = 4.0;
    newShot->inertia = 0.5f;
    newShot->creator = master;
	newShot->sprite = shotSprite;
	
    [[Shot sharedSet] addObject: newShot];
	[newShot release];
	
	return newShot;
	
}

+(void)makeAll {

	NSArray *a = [[Shot sharedSet] allObjects];

    int i;
    for (i=0;i<[a count];i++){

        Shot *sel = [a objectAtIndex: i];
        [sel doLevelWrap];
        
        sel->pos[0]+=sel->vel[0]*FRAME;
        sel->pos[1]+=sel->vel[1]*FRAME;
        
        
        if ([sel isOnScreen]){
            glPushMatrix();
                glTranslatef(sel->pos[0],sel->pos[1],-20.0);
                glRotatef(sel->rot-90,0,0,1);
                [sel->sprite draw];
            glPopMatrix();
        }
    
        if ( (sel->time-= 1.0*FRAME) <= 0){
            [[Shot sharedSet] removeObject: sel];
        }
                
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeFloat:time forKey:@"time"];
        //[coder encodeObject: creator forKey:@"creator"];
        
    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&time];
        //[coder encodeObject:creator];
        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        time = [coder decodeFloatForKey:@"time"];
        //creator = [coder decodeObjectForKey:@"creator"];
        
    } else {
        
        [coder decodeValueOfObjCType:@encode(float) at:&time];
        //creator = [[coder decodeObject] retain];
        
    }
    return self;
}


@end
