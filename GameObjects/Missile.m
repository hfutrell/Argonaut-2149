//
//  Missile.m
//  Argonaut
//
//  Created by Holmes Futrell on Sat Oct 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Missile.h"
#import <Asteroid.h>
#import <Particle.h>
#import "Explosion.h"

static GLSprite *missileGraphic,*glowGraphic;
static Model *bomb;
static GLTexture *bombTexture;
FocoaMod *warningSound,*fireSound;

@implementation Missile

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeFloat:timeSinceSmokePuff forKey:@"timeSinceSmokePuff"];
        [coder encodeFloat:timeSinceEnginePuff forKey:@"timeSinceEnginePuff"];
        [coder encodeFloat:maxDamage forKey:@"maxDamage"];
        [coder encodeFloat:minRange forKey:@"minRange"];
        [coder encodeFloat:maxRange forKey:@"maxRange"];
        [coder encodeFloat:timeTillExplosion forKey:@"timeTillExplosion"];
        [coder encodeFloat:startingTime forKey:@"startingTime"];
        [coder encodeFloat:warningInterval forKey:@"warningInterval"];
        [coder encodeFloat:timeTillWarning forKey:@"timeTillWarning"];
        [coder encodeObject: owner forKey: @"owner"];
        
    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&timeSinceSmokePuff];
        [coder encodeValueOfObjCType:@encode(float) at:&timeSinceEnginePuff];
        [coder encodeValueOfObjCType:@encode(float) at:&maxDamage];
        [coder encodeValueOfObjCType:@encode(float) at:&minRange];
        [coder encodeValueOfObjCType:@encode(float) at:&maxRange];
        [coder encodeValueOfObjCType:@encode(float) at:&timeTillExplosion];
        [coder encodeValueOfObjCType:@encode(float) at:&startingTime];
        [coder encodeValueOfObjCType:@encode(float) at:&warningInterval];
        [coder encodeValueOfObjCType:@encode(float) at:&timeTillWarning];
        //[coder encodeObject:owner];
        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        timeSinceSmokePuff = [coder decodeFloatForKey:@"timeSinceSmokePuff"];
        timeSinceEnginePuff = [coder decodeFloatForKey:@"timeSinceEnginePuff"];
        maxDamage = [coder decodeFloatForKey:@"maxDamage"];
        minRange = [coder decodeFloatForKey:@"minRange"];
        maxRange = [coder decodeFloatForKey:@"maxRange"];
        timeTillExplosion = [coder decodeFloatForKey:@"timeTillExplosion"];
        startingTime = [coder decodeFloatForKey:@"startingTime"];
        warningInterval = [coder decodeFloatForKey:@"warningInterval"];
        timeTillWarning = [coder decodeFloatForKey:@"timeTillWarning"];
        owner = [coder decodeObjectForKey:@"owner"];
        
    } else {
        
        [coder decodeValueOfObjCType:@encode(float) at:&timeSinceSmokePuff];
        [coder decodeValueOfObjCType:@encode(float) at:&timeSinceEnginePuff];
        [coder decodeValueOfObjCType:@encode(float) at:&maxDamage];
        [coder decodeValueOfObjCType:@encode(float) at:&minRange];
        [coder decodeValueOfObjCType:@encode(float) at:&maxRange];
        [coder decodeValueOfObjCType:@encode(float) at:&timeTillExplosion];
        [coder decodeValueOfObjCType:@encode(float) at:&startingTime];
        [coder decodeValueOfObjCType:@encode(float) at:&warningInterval];
        [coder decodeValueOfObjCType:@encode(float) at:&timeTillWarning];
        //owner = [[coder decodeObject] retain];
        
    }
    return self;
}

+(void)initAssets {

    
    bomb = [[Model alloc] initWithResource:@"data/models/bomb/bomb.obj" scale: 0.14];
    bombTexture = [GLTexture initWithResource:@"data/models/bomb/bomb.jpg"];
    glowGraphic = [[GLSprite alloc] initWithSingleImage:@"data/models/bomb/glow" extension:@".png"];
    missileGraphic = [[GLSprite alloc] initWithSingleImage:@"data/sprites/missiles/missmal" extension:@".tga"];
    warningSound = [[FocoaMod alloc] initWithResource:@"data/sounds/warning.wav" mode:FSOUND_HW3D];
    [warningSound setMinDistance: 400 maxDistance: 1200];//pretty long range (you need to hear this)
    fireSound = [[FocoaMod alloc] initWithResource:@"data/sounds/missilefire.wav" mode: FSOUND_HW3D];
    [fireSound setVolume: 50];
	[fireSound setMinDistance: 400 maxDistance: 800];//pretty long range (you need to hear this)
    [glowGraphic setCoordMode:@"center"];
    [missileGraphic setCoordMode:@"center"];

}

+(void)deallocAssets {
    
    [fireSound release];
    [glowGraphic release];
    [bomb release];
    [bombTexture release];
    [missileGraphic release];
    [warningSound release];
    
}

-(void)checkShipCollision {

    int i;
	NSArray *a = [[Ship sharedSet] allObjects];
    for (i=0;i<[a count];i++){
        Ship *sel = [a objectAtIndex:i];
        if ([self collideWithObject: sel] && sel != owner && sel != self){

            int previoushealth = shields;
            shields -= sel->shields;
            sel->shields-=previoushealth;
            
        }
    }
}

-(void)blowUp {

    [Explosion spawnLargeAtPoint:[self NSPointPosRep]];

    float damage;

    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex:i];
        damage=[self damageForDistance: [self distanceToObject: sel]];
        float angle = aDegreeTan2( pos[1]-sel->pos[1],pos[0]-sel->pos[0]);
        sel->vel[0] += degreeCosine(angle) * (damage/sel->inertia);
        sel->vel[1] += degreeSine(angle) * (damage/sel->inertia);
        sel->lastHitRotation = aDegreeTan2( sel->pos[1]-pos[1],sel->pos[0]-pos[0]);
        sel->health -= damage;

    }
	
	NSArray *a = [[Ship sharedSet] allObjects];
    for (i=0;i<[a count];i++){
    
        Ship *sel = [a objectAtIndex:i];
        if (sel != self && sel != owner && ![sel isKindOfClass:NSClassFromString(@"Missile")]){
            damage=[self damageForDistance: [self distanceToObject: sel]];
            sel->shields -= damage;
            float angle = atan2( sel->pos[1]-pos[1],sel->pos[0]-pos[0]);
            sel->vel[0] += cos(angle) * (damage/sel->inertia);
            sel->vel[1] += sin(angle) * (damage/sel->inertia);

        }
    }
    

}

-(id)init {

    self = [super init];
    return self;

}

-(float)radius {
    return 8.0f;
}
-(float)acceleration {
    return  1.0;   
}
-(float)danger {
    return 40.0;
}
-(float)turningSpeed {
    return 4.0f;
}
-(float)maxSpeed {
    return 8.0f;
}

+(id)spawnFromObject:(Ship *)master type:(id)theclass {

    Missile *newMissile = [super spawn];
        
    float initialSpeed = 0.0f;
    float secondsBeforeExplosion = 2.0f;
    
    
    newMissile->owner = master;
    newMissile->pos[0] = master->pos[0];
    newMissile->pos[1] = master->pos[1];
    newMissile->vel[0] = master->vel[0]+degreeCosine(master->rot)*initialSpeed;
    newMissile->vel[1] = master->vel[1]+degreeSine(master->rot)*initialSpeed;
    newMissile->timeTillExplosion = newMissile->startingTime = 60*secondsBeforeExplosion;
    
    newMissile->rot = master->rot;
    newMissile->control = CONTROL_COMPUTER;
    newMissile->shields =  [newMissile maxShields];//= 2 ;
    newMissile->inertia = 1;
    
    newMissile->maxDamage = 10.0;
    newMissile->minRange = 64.0;
    newMissile->maxRange = 110.0;

    [newMissile fireSound:fireSound];
    
    return newMissile;

}

-(float)maxShields{
    return 2;
}

//damage has a linear relationship with distance
-(float)damageForDistance:(float)distance {

    float damage = (((distance-minRange)*maxDamage)/(minRange-maxRange))+maxDamage;
    if (damage > maxDamage) damage = maxDamage;
    if (damage < 0) damage = 0;
    return damage;

}

-(void)make {

    [self retain];
    [self adjustSpeed];
    timeTillExplosion -= FRAME;
    if (timeTillExplosion <= 0) shields = 0;
    [self doLevelWrap];
    //[self checkShipCollision];
    //[self checkAsteroids];
    //[self checkShots];
    
    if (dangerMeter > 0.0007 && timeTillExplosion < 100){
        shields = 0;
    }
    
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;
    rot += rotvel*FRAME;
	
    [self assessDanger];
    
    [self accelerate];
    if ([self speed] > 3.0){ //don't turn immeadiatly, this looks weird
    
        dest = mostDangerousRotation;
        [self turnTowardsDest];
        
    }
    
    glPushMatrix();
    
        glTranslatef(pos[0],pos[1],0);
        glRotatef(rot+90,0,0,1);
        [missileGraphic draw];
    
    glPopMatrix();
    
    [self release];
    
}

-(void)accelerate {

    [super accelerate];
    
    float randomx = (float)[Randomness randomFloat: 0 max: 4]-2;
    float randomy = (float)[Randomness randomFloat: 0 max: 4]-2;
        
    timeSinceSmokePuff+=FRAME;
    
    if (timeSinceSmokePuff > 0.5f) {
        
        [Explosion SpawnAtX: pos[0]+randomx+degreeCosine(rot+180)*16.0f
            y: pos[1]+randomy+degreeSine(rot+180)*16.0f
            scale: 1.0
            rotation: rot+90
            sprite: [Explosion TrailSprite]];
		
        timeSinceSmokePuff=0.0f;
        
        NSPoint theOrigin;
        theOrigin.x = pos[0]+(randomx*3)+degreeCosine(rot+180)*16.0f;
        theOrigin.y = pos[1]+(randomy*3)+degreeSine(rot+180)*16.0f;
        
        [Particle spawnAtPoint: theOrigin
            rotation: [Randomness randomInt: 0 max: 20]
            speed: 0
            expansion: 0.4
            fade: -(1.0/100)+[Randomness randomFloat: 0 max: 0.005]
            size: 15
            sprite: [Particle smoke]];
        
    }

}


//override AI code because Missiles behave in several fundamentally different ways
//1)  we need to make sure missile AI doesn't account for other missiles
//2)  we need to make sure missile AI doesn't account for its owner
-(void)compForX:(float)xpos y:(float)ypos{

    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex:i];
        [self compensateForDangerOf: sel x:xpos y:ypos];
    }
    
	NSArray *a = [[Ship sharedSet] allObjects];
    for (i=0;i<[a count];i++){
    
        Ship *sel = [a objectAtIndex:i];
        if (sel != self && sel != owner && ![sel isKindOfClass:NSClassFromString(@"Missile")]){
            [self compensateForDangerOf: sel x:xpos y:ypos];
        }
    }
}

@end

@implementation DumbMissile

-(float)acceleration {
    return  0.5;   
}
-(float)danger {
    return 15.0;
}
-(float)turningSpeed {
    return 0.0f;
}
-(float)maxSpeed {
    return 16.0f;
}

+(id)spawnFromObject:(Ship *)master type:(id)theclass {

    DumbMissile *newMissile = [super spawnFromObject:master type:theclass];
        
    float secondsBeforeExplosion = 0.9f;
    newMissile->timeTillExplosion = newMissile->startingTime = 60*secondsBeforeExplosion;
    newMissile->inertia = 1;
    newMissile->maxDamage = 5.0;
    newMissile->minRange = 32.0;
    newMissile->maxRange = 96.0;
    newMissile->shields =  [newMissile maxShields];// 8;
    return newMissile;

}

-(float)maxShields{
    return 8;
}

-(void)make {

    [self retain];
    [self adjustSpeed];
	[self checkShots];
    timeTillExplosion -= FRAME;
    if (timeTillExplosion <= 0 ) shields = 0;
    [self doLevelWrap];
    [self checkAsteroids];
    [self checkShipCollision];
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;
    
    [self assessDanger];
    
    [self accelerate];
    
    glPushMatrix();
    
        glTranslatef(pos[0],pos[1],0);
        glRotatef(rot+90,0,0,1);
        [missileGraphic draw];
    
    glPopMatrix();
    
    [self release];
    
}

@end 

@implementation Nuke

-(float)acceleration {
    return  0;   
}
-(float)danger {
    return 10.0;
}
-(float)turningSpeed {
    return 0.0f;
}
-(float)maxSpeed {
    return 1.1f;
}

+(id)spawnFromObject:(Ship *)master type:(id)theclass {
    
    Nuke *newMissile = [super spawnFromObject:master type:theclass];
    
    float secondsBeforeExplosion = 60.0f;
    newMissile->timeTillExplosion = newMissile->startingTime = 60*secondsBeforeExplosion;
    newMissile->inertia = 1;
    newMissile->maxDamage = 60.0;
    newMissile->minRange = 128.0;
    newMissile->maxRange = 400.0;
    newMissile->warningInterval = 130;
    newMissile->shields = [newMissile maxShields]; //= 3;
    
	newMissile->vel[0] = 0.0;
	newMissile->vel[1] = 0.0;

    int i;
    for (i=0;i<3;i++){
        newMissile->rotaxis[i]=[Randomness randomFloat: -1 max: 1];
    }
	newMissile->rotvel = [Randomness randomFloat: 0 max: 6];
    
    return newMissile;
    
}

-(float)maxShields{
    return 10;
}

-(void)make {
    
    timeTillExplosion -= FRAME;
    if (timeTillExplosion <= 0 ) shields = 0;
    [self doLevelWrap];
    [self adjustSpeed];
    pos[0]+=vel[0]*FRAME;
    pos[1]+=vel[1]*FRAME;
    
	[self doAutoZap];
	[self checkShots];
	
    rot+=rotvel*FRAME;
			    
    float pulse = 1.0f - powf(timeSinceAutoZap - 10.0f, 2) / 100.0f;
    if (timeSinceAutoZap > 20.0f)
		pulse = 0.0f;
	else if (timeSinceAutoZap < 0.0)
		pulse = 0.0f;

    timeTillWarning-=FRAME;    
    if (timeTillWarning <= 0){
        timeTillWarning = warningInterval -= 20;
    }
    
    	
    glPushMatrix();
    
        glTranslatef(pos[0],pos[1],0);
        
        glPushMatrix();
        
            glRotatef(rot, rotaxis[0], rotaxis[1], rotaxis[2]);
        
            glEnable(GL_LIGHTING);
            glEnable(GL_DEPTH_TEST);
            
            [bombTexture bind];
            [bomb draw];
        
        glPopMatrix();
        
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_LIGHTING);
    
        glColor4f(1.0f ,1.0f ,1.0f, pulse);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        [glowGraphic draw];
        glColor4f(1.0f ,1.0f ,1.0f, 1.0f);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        
    glPopMatrix();
        
}

-(float)radius {
	return 10.0f;
}

-(void)blowUp {
    [Explosion spawnMediumAtPoint:[self NSPointPosRep]];
    [warningSound stop];
}


@end 