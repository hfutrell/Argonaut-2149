//
//  GatherBot.m
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GatherBot.h"
#import <Crystal.h>
#import <Explosion.h>

static GLSprite *shipSprite;
static FocoaMod *thrustSound;

@implementation GatherBot

-(void)blowUp {

    [Explosion spawnSmallAtPoint:[self NSPointPosRep]];

}

+(id)spawn {
    
    GatherBot *newBot;
    newBot = [super spawn];
        
    newBot->control = CONTROL_COMPUTER;
    //newBot->reloadTime = 15.0;
    newBot->shields = [newBot maxShields] ;
    //newBot->mode = MODE_GATHER;
    //newBot->AIMode = AI_SIMPLE;
    newBot->inertia = 1;
    newBot->crystals = [Randomness randomInt: 0 max: 3];
    //newBot->healthModules = [Randomness randomInt: 0 max: 1];
    
    [newBot setCoordsSafe];

    return newBot;
    
}

//set up that static crystal model which is shared by all crystal objects
+(void)InitAssets {

    shipSprite = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/prototype" extension:@".png"]setCoordMode:@"center"];
    thrustSound = [[FocoaMod alloc] initWithResource:@"data/sounds/gamer_thrust.wav" mode: FSOUND_HW3D];
    [thrustSound setMinDistance: 200 maxDistance: 800];
}

+(void)deallocAssets {
    
    [shipSprite release];
    [thrustSound release];

}

-(void)make {
    
        [self retain];
    
        if ([self isOnScreen]){
            glPushMatrix();
                    
                glTranslatef(pos[0],pos[1],-20);
                glRotatef(rot,0,0,1);
				glScalef(0.5, 0.5, 1.0);
				[shipSprite draw];     
        
            glPopMatrix();
        }
        
        pos[0]+=vel[0]*FRAME;
        pos[1]+=vel[1]*FRAME;
	
		rot += rotvel * FRAME;
        
        /*Here's where we do some crazy AI!  First the computer object surveys the situation assessing the danger brought on by asteroids and shots.  Danger is additive from the proximity of these objects. If the danger is beyond a comfortable threshold, the AI will set its bearing towards the safest point.  If not and there are crystals, the AI will try to capture them by setting its bearing at them.  If neither is true, the AI just floats like a lazy bum. */

        
        if (control == CONTROL_COMPUTER) {
                        
            //if (mode != MODE_RETREAT){
            
                if ((dangerMeter > 0.00015 && [[Crystal sharedSet] count] > 0) || dangerMeter > 0.0005 || [[Crystal sharedSet] count] == 0) { //fairly small danger
                    dest = safestRotation;
                    [self accelerateTowardsDest];
                }
                else {
                    dest = [self findNearestCrystal];
                    [self accelerateTowardsDest];
                }
                
            //}
            /*else {
                
                if (dangerMeter < 0.00010){
                    
                    dest = [self findNearestWall];
                    [self accelerateTowardsDest];
                
                }
                else {
                
                    dest = safestRotation;
                    [self accelerateTowardsDest];
                    
                }
                
            } */
        }
                
        //Retreat if there are no crystals on the screen
        //if ([[Crystal sharedArray] count] == 0 && [Randomness random: 0 maxValue: 300] == 1){
        //    [self retreat];
        //}
        
        if (shields <= 1){
            [self retreat];
        }
        
        //if (crystals >= 2){
        //    [self retreat];
        //}
        [super make];
        //if (shields <= 0){
        //    [Ship DestroyAtIndex: myIndex];
        //} 
        
        [self release];
        
}

-(void)accelerate {

    [super accelerate];
    if (!FSOUND_IsPlaying([thrustSound channel])){
        [self fireSound: thrustSound];
    }
        
    float randomx = (float)[Randomness randomFloat: 0 max: 4]-2;
    float randomy = (float)[Randomness randomFloat: 0 max: 4]-2;
        
    [Explosion SpawnAtX: pos[0]+randomx+degreeCosine(rot+180)*[self radius]
        y: pos[1]+randomy+degreeSine(rot+180)*[self radius]
        scale: 1.0
        rotation: rot+90
        sprite: [Explosion DualSprite]];

}

-(float)maxShields{
    return 4;
}
-(float)reloadTime{
    return 15;
}
-(unsigned int)healthModules {
    return 0;   
}

-(float)radius {
    return 8.0f;
}
-(float)acceleration {
    return  0.8;   
}
-(float)danger {
    return 0.2;
}
-(float)turningSpeed {
    return 8.0f;
}
-(float)maxSpeed {
    return 6.0f;
}

@end
