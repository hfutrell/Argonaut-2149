//
//  Powerup.m
//  Argonaut
//
//  Created by Holmes Futrell on Sat Jul 19 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import "Powerup.h"
#import "Shot.h"
#import "Explosion.h"

#define MAXSPEED 0.5

static NSMutableSet *sharedSet;
static Model *powerupModel;
static GLTexture *powerupTexture;
static GLTexture *crateTexture;


@implementation Powerup

+(void)drawModelOfID:(int)model {
    if (model == 0 ){
        [powerupTexture bind];
    }
    else {
        [crateTexture bind];
    }
    [powerupModel draw];
}

//this string is passed once in exchange for a draw ID, rather than passing the string each frame when its drawn
//(which I'm not comfortable doing)
+(int)drawIDForType:(NSString *)_type {
    if ([_type isEqual:@"Shield Charge"] || [_type isEqual:@"Shield Restore"]){
        return 0;
    }
    else {
        return 1;
    }
}

//set up that static powerup model which is shared by all powerup objects
+(void)initAssets {

    powerupModel = [[Model alloc] initWithResource:@"data/models/powerups/box.obj" scale: 0.1];
	crateTexture = [GLTexture initWithResource:@"data/models/powerups/crate.jpg"];
	powerupTexture = [GLTexture initWithResource:@"data/models/powerups/medecine.jpg"];

}

+(void)deallocAssets {

    [powerupModel release];
    [powerupTexture release];
    [crateTexture release];
    [sharedSet release];
    sharedSet = nil;

}

+(id)sharedSet {
    return !sharedSet ? sharedSet = [NSMutableSet new] : sharedSet;
}

-(float)radius {
    return 20.0f;
}
-(float)danger {
    return -5.0;
}
-(float)maxSpeed {
    return 1;
}

//makes a new powerup object and adds it to the shared array
//after that point it can be referenced by calling up the shared array
+(id)spawnAtPoint:(NSPoint)theOrigin type:(NSString *)_type {
    
    Powerup *newPowerup = [[Powerup alloc] init];
    
    [[Powerup sharedSet] addObject: newPowerup];
    
    newPowerup->drawID = [Powerup drawIDForType: _type];
    newPowerup->pos[0] = theOrigin.x;
    newPowerup->pos[1] = theOrigin.y;
    newPowerup->inertia = 1;
    newPowerup->timeLeft = (60*60)+[Randomness randomFloat: 0 max: 300];
    newPowerup->type = [_type retain];
    
    int n;
	newPowerup->rotvel = [Randomness randomFloat: 0 max: 5]-2.5;
   
	 for (n=0;n<2;n++){
        newPowerup->vel[n] = [Randomness randomFloat: 0 max: 5]-2.5;
    }
        
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Powerup_Spawned" object: newPowerup];
        
	[newPowerup release];
		
    return newPowerup;

}

+(id)spawn {
    Powerup *newPowerup = [Powerup spawnAtPoint:NSMakePoint(0,0) type:@"Shield Charge"];
    [newPowerup setCoordsRandomWall];
    return newPowerup;
}

-(void)destroy {

    //make explosions and particles as well
    NSPoint theOrigin = NSMakePoint(pos[0],pos[1]);
    [Explosion spawnSmallAtPoint: theOrigin];
    [[Powerup sharedSet] removeObject: self];

}

-(void)checkShots {

    int i;
	
	NSArray *a = [[Shot sharedSet] allObjects];
	
    for (i=0;i<[a count];i++){
        Shot *sel = [a objectAtIndex: i];
        if ([self collideWithObject: sel]){
            [[Shot sharedSet] removeObject: sel];
            [self destroy];
        }
    }      
}

+(void)makeAll {

    glEnable(GL_DEPTH_TEST);
	NSArray *a = [[Powerup sharedSet] allObjects];
	int i;
	for (i=0; i<[a count]; i++) {
		Powerup *curr = (Powerup *)[a objectAtIndex: i];
		[curr make];
	}
	
    glDisable(GL_DEPTH_TEST);
    
}

-(void)make {

    [self retain];
    
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;

    [self adjustSpeed];
    [self doLevelWrap];

    if ([self isOnScreen]){
        //[self checkShots];//for speeds sake, only check for shots when onscreen
        glPushMatrix();
            glTranslatef(pos[0],pos[1],-20);
            
			rot += rotvel*FRAME;
			glRotatef(rot, rotaxis[0], rotaxis[1], rotaxis[2]);
            [Powerup drawModelOfID: drawID];
        glPopMatrix();
    }
    timeLeft -= FRAME;
    if (timeLeft < 0) [self destroy];
    
    [self release];

}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeInt:drawID forKey:@"drawID"];
        [coder encodeFloat:timeLeft forKey:@"timeLeft"];
        [coder encodeObject:type forKey:@"type"];
        
    } else {
        
        [coder encodeValueOfObjCType:@encode(int) at:&drawID];
        [coder encodeValueOfObjCType:@encode(float) at:&timeLeft];
        [coder encodeObject:type];

        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        drawID = [coder decodeIntForKey:@"drawID"];
        timeLeft = [coder decodeFloatForKey:@"timeLeft"];
        type = [coder decodeObjectForKey:@"type"];
        
    } else {
        
        [coder decodeValueOfObjCType:@encode(int) at:&drawID];
        [coder decodeValueOfObjCType:@encode(float) at:&timeLeft];
        type = [[coder decodeObject] retain];
        
    }
    return self;
}

@end