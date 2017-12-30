//
//  GatherBot.m
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Fighter.h"
#import <Explosion.h>
#import <Particle.h>
#import <Asteroid.h>

static GLSprite *fighterSprite;
static FocoaMod *shootSound;

@implementation Fighter

-(void)blowUp {
    
    [Explosion spawnMediumAtPoint:[self NSPointPosRep]];
    
}

+(id)spawn {
    
    Fighter *newBot;
    newBot = [super spawn];
    
    newBot->radius = 18.0;
    newBot->maxspeed = 7.0f;
    newBot->acceleration = 0.25; //was .18
    newBot->turningSpeed = 8;
    newBot->control = CONTROL_COMPUTER;
    newBot->reloadTime = 7.5;
    newBot->maxShields = newBot->shields = 7;
    newBot->danger = 10.0;
    newBot->mode = MODE_ATTACK;
    newBot->AIMode = AI_SIMPLE;
    newBot->inertia = 4;
    newBot->healthModules = 1;
    newBot->crystals = [Randomness randomInt: 0 max: 3];
        
    [newBot setCoordsSafe];
    
    return newBot;
    
}

//set up that static crystal model which is shared by all crystal objects
+(void)initAssets {
    
    //don't load the assets if they're already loaded!f
    fighterSprite = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/fighter" extension:@".tga"] setCoordMode:@"center"];
    shootSound = [[FocoaMod alloc] initWithResource:@"data/sounds/plasma_blast.wav" mode: FSOUND_HW3D];
    [shootSound setMinDistance: 200 maxDistance: 800];
    
    
}

+(void)deallocAssets {
    
    [fighterSprite release];
    [shootSound release];
    
}

-(void)make {
    
    //NOTE: PIRATES DON'T CALL SUPER MAKE
    [self retain];
    [self adjustSpeed];
    timeBeforeShoot -= FRAME;
    [self doLevelWrap];
    [self assessDanger];
    if (control == CONTROL_HUMAN){
        [self setToListeningPoint];
    }
    [self doRedTimeEffect];
    [self release];
    useItemTime -= FRAME;
    
    if ([self isOnScreen]){
        
        [self checkShots];
        [self checkAsteroids];
        glPushMatrix();
        
        glTranslatef(pos[0],pos[1],-20);
        glRotatef(rot[2],0,0,1);
        [fighterSprite draw];     
        
        glPopMatrix();
    }
    
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;
    
    rot[2]+=rotvel[2]*FRAME;
    
    if (control == CONTROL_COMPUTER) {
        
        if (dangerMeter > 0.00008) { //if he doesn't turn at this point, he'll get hit
            dest = safestRotation;
            [self accelerateTowardsDest];
        }
        else {
            if (([self aimedAtAsteroid] || [self aimedAtShipOfClass:NSClassFromString(@"Argonaut") tolerence:2 distance: NO])){
                [self fire];
            }
            else {
                dest = [self findNearestShipOfClass:NSClassFromString(@"Argonaut")];
                [self accelerateTowardsDest];
            }
        }
    }
}


-(void)fire {
    [super fire];
}

-(void)fireSuccess {
    
    [self fireSound: shootSound];
    [super fireSuccess];
    
}

-(void)accelerate {
    
    [super accelerate];
    
    float randomx = (float)[Randomness randomFloat: 0 max: 4]-2;
    float randomy = (float)[Randomness randomFloat: 0 max: 4]-2;
    
    timeSinceLastPoof+=FRAME;
    
    if (timeSinceLastPoof > 1.0f) {
        
        [Explosion SpawnAtX: pos[0]+randomx+degreeCosine(rot[2]+180)*radius
                          y: pos[1]+randomy+degreeSine(rot[2]+180)*radius
                      scale: 1.0
                   rotation: rot[2]+90
                     sprite: [Explosion TrailSprite]];
        
        timeSinceLastPoof=0.0f;
        
        NSPoint theOrigin;
        theOrigin.x = pos[0]+(randomx*3)+degreeCosine(rot[2]+180)*radius;
        theOrigin.y = pos[1]+(randomy*3)+degreeSine(rot[2]+180)*radius;
        
        [Particle spawnAtPoint: theOrigin
                      rotation: [Randomness randomInt: 0 max: 360]
                         speed: 0
                     expansion: 0.8
                          fade: -(1.0/50)-[Randomness randomFloat: 0 max: 0.01]
                          size: 15
                        sprite: [Particle smoke]];
        
    }
    
}

-(void)compForX:(float)xpos y:(float)ypos{
    
    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex:i];
        [self compensateForDangerOf: sel x:xpos y:ypos];
    }
}

@end
