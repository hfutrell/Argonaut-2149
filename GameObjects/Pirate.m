//
//  GatherBot.m
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Pirate.h"
#import <Explosion.h>
#import <Particle.h>
#import <Asteroid.h>
#import "Shot.h"

static GLSprite *pirateSprite, *dreadPirateSprite;
static FocoaMod *shootSound;

@interface Pirate (internalMethods) 
-(NSPoint)turretLocation:(int)number;
-(float)reloadTime;
@end

@implementation Pirate

-(void)blowUp {

    [Explosion spawnLargeAtPoint:[self NSPointPosRep]];

}

-(float)radius {
    return 24.0f;
}
-(float)acceleration {
    return  0.15;   
}
-(float)danger {
    return 10.0;
}
-(float)turningSpeed {
    return 1.8f;
}
-(float)maxSpeed {
    return 3.5f;
}

+(id)spawn {

    Pirate *newBot;
    newBot = [super spawn];
    newBot->control = CONTROL_COMPUTER;
    //newBot->reloadTime = 15.0;
    newBot->shields =  [newBot maxShields];
    //newBot->mode = MODE_ATTACK;
    //newBot->AIMode = AI_SIMPLE;
    newBot->inertia = 4;
    //newBot->healthModules = 1;
    newBot->crystals = [Randomness randomInt: 0 max: 3];
    newBot->screenTime = 0;
	newBot->sprite = pirateSprite;
	
    [newBot gatherPowerupOfType:@"Dumb Missile"];
    [newBot gatherPowerupOfType:@"Dumb Missile"];
    [newBot gatherPowerupOfType:@"Dumb Missile"];
    
    [newBot setCoordsSafe];
    
    return newBot;
    
}

//set up that static crystal model which is shared by all crystal objects
+(void)InitAssets {

    //don't load the assets if they're already loaded!f
    pirateSprite = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/player2" extension:@".png"] setCoordMode:@"center"];
	dreadPirateSprite = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/dreadpirate" extension:@".png"] setCoordMode:@"center"];

    shootSound = [[FocoaMod alloc] initWithResource:@"data/sounds/plasma_blast.wav" mode: FSOUND_HW3D];
    [shootSound setMinDistance: 200 maxDistance: 800];


}

+(void)deallocAssets {

    [pirateSprite release];
	[dreadPirateSprite release];

    [shootSound release];

}

-(void)make {
    
    //NOTE: PIRATES DON'T CALL SUPER MAKE
    [self retain];
    [self adjustSpeed];
    timeBeforeShoot -= FRAME;
    [self doLevelWrap];
    if ([self isOnScreen]) 
    [self checkShots];
    [self assessDanger];
    [self doRedTimeEffect];
    [self release];
    useItemTime -= FRAME;
    
    if ([self isOnScreen]){
        [self checkAsteroids];
        glPushMatrix();
                
            glTranslatef(pos[0],pos[1],-20);
            glRotatef(rot,0,0,1);
			glScalef(0.5, 0.5, 1.0);
			[sprite draw];     
    
        glPopMatrix();
    }
    
	rot += rotvel * FRAME;
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;

	
    if (control == CONTROL_COMPUTER) {

		if ([self isOnScreen]) screenTime += FRAME;
        
        if (dangerMeter > 0.00009) { //if he doesn't turn at this point, he'll get hit
            dest = safestRotation;
            [self accelerateTowardsDest];
        }
        else {
            Ship *a = (Ship *)[self findNearestShipOfClass:NSClassFromString(@"Nuke")];
			if (!a) {
				a = (Ship *)[self findNearestShipOfClass:NSClassFromString(@"Argonaut")];
			}
			if (!a) {
				dest = 0.0;
			}
			else {
				dest = dest + angleBetweenVectors(NSMakePoint(cos(dest * pi/180.0), sin(dest * pi/180.0)),[self aimForTarget: a projectileSpeed: 18 time: nil]);
			}
			[self accelerateTowardsDest];
        }

        if ([self canFire] && [self isOnScreen]){
            if (([self aimedAtShipOfClass:NSClassFromString(@"Argonaut") speed: 18 tolerence:10 distance: NO] \
				|| [self aimedAtShipOfClass:NSClassFromString(@"Nuke") speed: 18 tolerence:10 distance: NO] \
				|| [self aimedAtAsteroid])\
				 && ![self aimedAtShipOfClass:NSClassFromString(@"Pirate") speed: 18 tolerence:5 distance: NO]) {
                [self fire];
            }
        }
        if ([self canUsePowerup] && screenTime > 120 && [self isOnScreen]){
            if (([self aimedAtShipOfClass:NSClassFromString(@"Argonaut") speed: 8 tolerence: 5 distance: YES] \
				|| [self aimedAtShipOfClass:NSClassFromString(@"Nuke") speed: 8 tolerence: 5 distance: YES]) \
			  && ![self aimedAtShipOfClass:NSClassFromString(@"Pirate") speed: 8 tolerence:20 distance: NO]){
                [self useSelectedItem];   
            }
        }
    }
}

-(float)useItemTime {
	return 200.0f;
}

-(void)fire {
    [super fire];
}

-(void)fireSuccess {

	shotParity = !shotParity;
	
	NSPoint t = [self turretLocation: shotParity];
    timeBeforeShoot = [self reloadTime];

    [self fireSound: shootSound];

	Shot *s = [Shot SpawnFrom: self];
	[s setLocation: NSMakePoint(pos[0] + t.x, pos[1] + t.y)];

}

/*-(void)turnLeft {

    if (rotvel[2] < maxRotVel) rotvel[2]+=turningSpeed*FRAME;
    
}

-(void)turnRight {

    if (rotvel[2] > -maxRotVel) rotvel[2]-=turningSpeed*FRAME;

} */

-(NSPoint)turretLocation:(int)number {
	
	NSPoint t;
	if (number == 0)
		t = NSMakePoint(39-32, 13-32);
	else
		t = NSMakePoint(39-32, 51-32);
	
	float s = degreeSine(rot);
	float c = degreeCosine(rot);

	return NSMakePoint(c * t.x - s * t.y, s * t.x + c * t.y);
		
}

-(NSPoint)engineLocation {

	NSPoint t = NSMakePoint(-32, 0);
	
	float s = degreeSine(rot);
	float c = degreeCosine(rot);

	return NSMakePoint(c * t.x - s * t.y, s * t.x + c * t.y);

}

-(void)accelerate {

    [super accelerate];
    
    float randomx = (float)[Randomness randomFloat: 0 max: 4]-2;
    float randomy = (float)[Randomness randomFloat: 0 max: 4]-2;
        
    timeSinceLastPoof+=FRAME;
    
    if (timeSinceLastPoof > 1.0f) {
        
		NSPoint engineLoc = [self engineLocation];
		
        Explosion *e = [Explosion SpawnAtX: pos[0]+randomx+engineLoc.x
            y: pos[1]+randomy+engineLoc.y
            scale: 1.0
            rotation: rot+90
            sprite: [Explosion TrailSprite]];
        
		if (e) {
			e->vel[0] = vel[0] - 2.0f * cos(rot * pi / 180.0f);
			e->vel[1] = vel[1] - 2.0f * sin(rot * pi / 180.0f);
		}
		
        timeSinceLastPoof=0.0f;
        
        NSPoint theOrigin;
        theOrigin.x = pos[0]+(randomx*3)+degreeCosine(rot+180)*[self radius];
        theOrigin.y = pos[1]+(randomy*3)+degreeSine(rot+180)*[self radius];
        
        Particle *p = [Particle spawnAtPoint: theOrigin
            rotation: [Randomness randomInt: 0 max: 360]
            speed: 0
            expansion: 0.8
            fade: -(1.0/50)-[Randomness randomFloat: 0 max: 0.01]
            size: 15
            sprite: [Particle smoke]];
     
		if (p) {
			p->vel[0] = vel[0] - 2.0f * cos(rot * pi / 180.0f);
			p->vel[1] = vel[1] - 2.0f * sin(rot * pi / 180.0f);
		}
		      
    }

}

-(void)compForX:(float)xpos y:(float)ypos{
    
    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex:i];
        [self compensateForDangerOf: sel x:xpos y:ypos];
    }
	NSArray *a = [[Ship sharedSet] allObjects];
    for (i=0;i<[a count];i++){
        
        Ship *sel = [a objectAtIndex:i];
        if (sel != self && [sel isKindOfClass:NSClassFromString(@"Pirate")]){
            [self compensateForDangerOf: sel x:xpos y:ypos];
        }
        
    }
}

-(float)maxShields{
    return 10;
}
-(float)reloadTime{
    return 15;
}
-(unsigned int)healthModules {
    return 2;   
}

@end

@implementation DreadPirate
-(float)reloadTime{
    return 5;
}
-(unsigned int)healthModules {
    return 5;   
}
-(float)useItemTime {
	return 100.0f;
}
-(float)maxShields {
	return 20;
}
-(float)acceleration {
    return  0.15;   
}
-(float)danger {
    return 10.0;
}
-(float)turningSpeed {
    return 4.0f;
}
-(float)maxSpeed {
    return 4.00;
}
-(float)shieldRechargeRate {
	return 0.01;
}

+(id)spawn {
	Pirate *newPirate;
	newPirate = [super spawn];
	
	[newPirate gatherPowerupOfType:@"Dumb Missile"];
    [newPirate gatherPowerupOfType:@"Dumb Missile"];
    [newPirate gatherPowerupOfType:@"Dumb Missile"];
	newPirate->sprite = dreadPirateSprite;

	return newPirate;
}

@end
