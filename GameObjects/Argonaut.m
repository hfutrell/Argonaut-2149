//
//  GatherBot.m
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Argonaut.h"
#import <Explosion.h>
#import <Particle.h>
#import <Asteroid.h>
#import <Shot.h>

static GLSprite *argonautSpritePlayer, *argonautSpriteCPU;
static FocoaMod *shootSound;

@implementation Argonaut

-(void)blowUp {
    [Explosion spawnLargeAtPoint:[self NSPointPosRep]];
}

-(float)radius {
    return 18.0f;
}
-(float)acceleration {
    return  0.25;   
}
-(float)danger {
    return 2.0;
}
-(float)turningSpeed {
    return 4.0f;
}
-(float)maxSpeed {
    return 5.75f;
}

-(float)useItemTime {
	return 20.0f;
}

+(id)spawn {

    Argonaut *newBot;
    newBot = [super spawn];
    
    newBot->control = CONTROL_COMPUTER;
    //newBot->reloadTime = 15.0;
    newBot->shields = [newBot maxShields]; //16;
    //newBot->mode = MODE_ATTACK;
    //newBot->AIMode = AI_SIMPLE;
    newBot->inertia = 3;
    newBot->invincableTime = 4*60;
    
    [newBot setCoordsSafe];
    
    return newBot;
    
}

//set up that static crystal model which is shared by all crystal objects
+(void)initAssets {

    //don't load the assets if they're already loaded!f
    argonautSpritePlayer = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/player" extension:@".png"] setCoordMode:@"center"];
	argonautSpriteCPU = [[[GLSprite alloc] initWithSingleImage:@"data/sprites/friend" extension:@".png"] setCoordMode:@"center"];
	shootSound = [[FocoaMod alloc] initWithResource:@"data/sounds/plasma_blast.wav" mode: FSOUND_HW3D];
    [shootSound setMinDistance: 200 maxDistance: 800];

}

+(void)deallocAssets {

    [argonautSpritePlayer release];
	[argonautSpriteCPU release];
    [shootSound release];

}

-(float)shieldRechargeRate {
	if (control == CONTROL_COMPUTER) return 0.005;
	else return 0.00;
}

-(void)make {

    [super make];
    
    if ( (invincableTime-= FRAME) > 0) shields = [self maxShields];
    
    if ([self isOnScreen]){
        glPushMatrix();
                
            glTranslatef(pos[0],pos[1],-20);
            glRotatef(rot,0,0,1);
            glScalef(0.5, 0.5, 1.0);
			
			if (control == CONTROL_COMPUTER)
				[argonautSpriteCPU draw];
			else
				[argonautSpritePlayer draw];

    
        glPopMatrix();
    }
    
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;
            
    rot+=rotvel*FRAME;
    
	rotvel=0;
    
	
    if (control == CONTROL_COMPUTER) {

		//[self assessDanger];
		   
        if (dangerMeter > 0.0001) { //if he doesn't turn at this point, he'll get hit
            dest = safestRotation;
            [self accelerateTowardsDest];
        }
        else {
		
			Ship *a = (Ship *)[self findNearestShipOfClass:NSClassFromString(@"Pirate")];
			if (!a) {
				Asteroid *b = [self findNearestAsteroid];
				if (b != nil)
				dest = dest + angleBetweenVectors(NSMakePoint(cos(dest * pi/180.0), sin(dest * pi/180.0)),[self aimForTarget: b projectileSpeed: 18 time: nil]);
			}
			else {
				dest = dest + angleBetweenVectors(NSMakePoint(cos(dest * pi/180.0), sin(dest * pi/180.0)),[self aimForTarget: a projectileSpeed: 18 time: nil]);
			}
			if (dest > 360) dest -= 360;
			if (dest < 0) dest += 360;
		
            [self accelerateTowardsDest];
        }
        if ( [self canFire] ){
            if ( [self aimedAtAsteroid] ) {
                [self fire];
            }
            if ([self aimedAtShipOfClass:NSClassFromString(@"Pirate") speed: 18 tolerence:15 distance:NO] && ![self aimedAtShipOfClass:NSClassFromString(@"Argonaut") speed: 18 tolerence:20 distance:NO]){
                [self fire];
            }
			if ([self aimedAtShipOfClass:NSClassFromString(@"Pirate") speed: 8 tolerence: 5 distance: YES] && ![self aimedAtShipOfClass:NSClassFromString(@"Argonaut") speed: 8 tolerence:20 distance:NO]){
				[self useSelectedItem];   
			}

        }
    }
}

-(NSPoint)engineLocation:(int)number {

	NSPoint t;
	if (number == 0)
		t = NSMakePoint(2 -32, 22-32);
	else
		t = NSMakePoint(2 -32, 42-32);
	
	float s = degreeSine(rot);
	float c = degreeCosine(rot);

	return NSMakePoint(c * t.x - s * t.y, s * t.x + c * t.y);

}

-(NSPoint)turretLocation:(int)number {
	
	NSPoint t;
	if (number == 0)
		t = NSMakePoint(20-32, 22-32);
	else
		t = NSMakePoint(20-32, 42-32);
	
	float s = degreeSine(rot);
	float c = degreeCosine(rot);

	return NSMakePoint(c * t.x - s * t.y, s * t.x + c * t.y);
		
}

-(void)fireSuccess {

    Shot *shot = [Shot SpawnFrom: self];
    timeBeforeShoot = [self reloadTime];

    [self fireSound: shootSound];

	shotParity = !shotParity;
	NSPoint t = [self turretLocation: shotParity];
	
	[shot setLocation: NSMakePoint(pos[0] + t.x, pos[1] + t.y)];


}

-(void)doEnginePoof {

    float randomx = (float)[Randomness randomFloat: 0 max: 2]-1;
    float randomy = (float)[Randomness randomFloat: 0 max: 2]-1;
        
	NSPoint engineLoc = [self engineLocation: engineParity];
	engineParity = !engineParity;

	Explosion *e = [Explosion SpawnAtX: pos[0]+engineLoc.x+randomx
		y: pos[1]+engineLoc.y+randomy
		scale: 1.0
		rotation: rot+90
		sprite: [Explosion TrailSprite]];
	
	if (e) {
		e->vel[0] = vel[0] - 2.0f * cos(rot * pi / 180.0f);
		e->vel[1] = vel[1] - 2.0f * sin(rot * pi / 180.0f);
	}

	timeSinceLastPoof=0.0f;
	
	NSPoint theOrigin;
	theOrigin.x = pos[0]+(randomx*3)+engineLoc.x;
	theOrigin.y = pos[1]+(randomy*3)+engineLoc.y;
	
	Particle *p = [Particle spawnAtPoint: theOrigin
		rotation: rot+180
		speed: 0
		expansion: 0.6
		fade: -(1.0/60.0)-[Randomness randomFloat: 0 max: 0.005]
		size: 18
		sprite: [Particle smoke]];
	
	if (p) {
		p->vel[0] = vel[0] - 2.0f * cos(rot * pi / 180.0f);
		p->vel[1] = vel[1] - 2.0f * sin(rot * pi / 180.0f);
	}

}

-(void)accelerate {

    [super accelerate];
	
	if (timeSinceLastPoof > 0.5f) {
		[self doEnginePoof];
		//[self doEnginePoof];
	}
    timeSinceLastPoof+=FRAME;

}

-(float)maxShields{
    return 20;
}
-(float)reloadTime{
    return 7;
}
-(unsigned int)healthModules {
    return 0;   
}

@end
