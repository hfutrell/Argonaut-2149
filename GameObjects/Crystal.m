//
//  Crystal.m
//  Argonaut
//
//  Created by Holmes Futrell on Sat Jul 19 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import "Crystal.h"
#import "Shot.h"
#import "Explosion.h"

#define MAXSPEED 2.0

static NSMutableSet *sharedSet;
static Model *crystalModel;
static GLTexture *crystalTexture;
static GLSprite *glow;

@implementation Crystal

+(id)sharedSet {
    return !sharedSet ? sharedSet = [NSMutableSet new] : sharedSet;
}

+(void)setSharedSet:(NSMutableSet *)newSet {
     
    if (sharedSet) [sharedSet release];
    sharedSet = [newSet retain];
    
}

//makes a new crystal object and adds it to the shared array
//after that point it can be referenced by calling up the shared array
+(id)SpawnAtX:(float)x y:(float)y {

        Crystal *newCrystal = [[Crystal alloc] init];
        
        [[Crystal sharedSet] addObject: newCrystal];
        
        newCrystal->pos[0] = x;
        newCrystal->pos[1] = y;
        newCrystal->inertia = 1;
            
        int n;
        for (n=0;n<3;n++){
            newCrystal->rotaxis[n] = [Randomness randomFloat: -1 max: 1];
        }
		newCrystal->rotvel = [Randomness randomFloat: 0 max: 10];
		
        for (n=0;n<2;n++){
            newCrystal->vel[n] = [Randomness randomFloat: 0 max: 5]-2.5;
        }
        
        newCrystal->time = 700;
        //newCrystal->danger = ; //crystals are anti-danger, they are good!
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"Crystal_Spawned" object: newCrystal];
                
		[newCrystal release];
		
        return newCrystal;
    
}

+(void)spawn {
    Crystal *newCrystal = [Crystal SpawnAtX: 0 y: 0];
    [newCrystal setCoordsRandomWall];
}

//set up that static crystal model which is shared by all crystal objects
+(void)InitAssets {

    crystalModel = [[Model alloc] initWithResource:@"data/models/crystal/crystal.obj" scale: 0.1];
    glow = [[[GLSprite alloc] initWithSingleImage:@"data/models/crystal/glow" extension:@".jpg"]setCoordMode:@"center"];
    crystalTexture = [GLTexture initWithResource:@"data/models/crystal/crystal.jpg"];

}

+(void)deallocAssets {

    [crystalModel release];
    [crystalTexture release];
    [glow release];
    [sharedSet release];
    sharedSet = nil;

}

-(void)destroy {

    //make explosions and particles as well
    [[Crystal sharedSet] removeObject: self];

}

-(void)checkShots {

    int i;
	
	NSArray * a = [[Shot sharedSet] allObjects];
	
    for (i=0;i<[a count];i++){
        
        Shot *sel = [a objectAtIndex: i];
        if ([self collideWithObject: sel] && sel->creator != self){
            
            NSPoint theOrigin = NSMakePoint(pos[0],pos[1]);
            [Explosion spawnSmallAtPoint: theOrigin];
            [[Shot sharedSet] removeObject: sel];
            [self destroy];                                                          
        }
    }      

}

+(void)makeAll {

    
    glDisable(GL_LIGHTING);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	
	NSArray *a = [[Crystal sharedSet] allObjects];
	int i;
	for (i=0; i<[a count]; i++) {
		[(Crystal *)[a objectAtIndex: i] make];
	}
	
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_LIGHTING);
    glColor4f(1.0,1.0,1.0,1.0);
        
}

-(void)make {

        [self retain];
        
        pos[0]+=vel[0]*FRAME;
        pos[1]+=vel[1]*FRAME;
    
        float speed = sqrt(pow(vel[0],2)+pow(vel[1],2));
        if ( speed > MAXSPEED ) {
            vel[0] /= (speed/MAXSPEED);
            vel[1] /= (speed/MAXSPEED);
        }
        [self doLevelWrap];

    
        if ([self isOnScreen]){
    
            //[self checkShots];//for speeds sake, only if the crystal is onscreen
    
            glPushMatrix();
                    
                glTranslatef(pos[0],pos[1],-20);
        
                glDisable(GL_DEPTH_TEST);
                glColor4f(1.0,1.0,1.0,1.0);
                [glow draw];
                glEnable(GL_DEPTH_TEST);
                    
                glColor4f(1.0,1.0,1.0,0.9);
                
				rot += rotvel * FRAME;
				
                glRotatef(rot, rotaxis[0], rotaxis[1], rotaxis[2]);            
                [GLTexture setSphereMapping: YES];
                [crystalTexture bind];
                [crystalModel draw];
                [GLTexture setSphereMapping: NO];
        
            glPopMatrix();
        
        }
        [self release];

}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeFloat:time forKey:@"time"];
        
    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&time];
        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        time = [coder decodeFloatForKey:@"time"];
        
    } else {
        
        [coder decodeValueOfObjCType:@encode(float) at:&time];
        
    }
    return self;
}

-(float)maxSpeed {
    
    return MAXSPEED;
    
}

-(float)radius {
    
    return 16.0f;

}

-(float)danger {

    return -.25;

}

@end