//
//  Asteroid.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Asteroid.h"

#import "Crystal.h"
#import "Shot.h"
#import "Explosion.h"
#import "Particle.h"

#define HUGE_INERTIA 10
#define LARGE_INERTIA 4
#define MEDIUM_INERTIA 2
#define SMALL_INERTIA 1

@implementation Asteroid

static NSMutableArray *sharedArray;
static Model *smallModel, *mediumModel, *largeModel,*hugeModel;
static GLTexture *asteroidTexture,*asteroidTexture2;

static BOOL allowsSpawning = YES;

+(void)InitAssets {

    float baseScale = 120; //bigger

    smallModel  = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid1.obj" scale: baseScale * 1.0/3.0];
    mediumModel = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid2.obj"scale: baseScale * 2.0/3.0];
    largeModel  = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid2.obj" scale: baseScale]; //to save polygons
    hugeModel   = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid4.obj" scale: baseScale * 2.0];
    
	asteroidTexture2  = [GLTexture initWithResource:@"data/models/asteroid/bigasteroid.jpg"];
	asteroidTexture  = [GLTexture initWithResource:@"data/models/asteroid/asteroid.jpg"];
	
	//iceteroidTexture  = [GLTexture initWithTGAResource:@"data/models/asteroid/iceteroid.tga"];
    //iceteroidTexture2  = [GLTexture initWithResource:@"data/models/asteroid/bigiceteroid.jpg"];

	//glowSprite  = [[[GLSprite alloc] initWithSingleImage:@"data/models/asteroid/glow" extension:@".jpg"] setCoordMode:@"center"];;
    
}

+(Model *)smallModel {
    return smallModel; 
}
+(Model *)mediumModel {
    return mediumModel;
}
+(Model *)largeModel {
    return largeModel;
}
+(Model *)hugeModel {
    return hugeModel;
}
+(GLTexture *)asteroidTexture {
    return asteroidTexture;
}
+(GLTexture *)asteroidTexture2 {
    return asteroidTexture2;
}

+(void)deallocAssets {

    [smallModel release];
    [mediumModel release];
    [largeModel release];
    [hugeModel release];
    [asteroidTexture release];
    [asteroidTexture2 release];
    [sharedArray release];
    sharedArray = nil;
    allowsSpawning = YES;

}

+(void)setSharedArray:(NSArray *)newArray {
   
    if (sharedArray) [sharedArray release];
    sharedArray = [newArray retain];
    
}

+(id)sharedArray {
    return !sharedArray ? sharedArray = [[NSMutableArray alloc] init] : sharedArray;
}

+(id)SpawnOfSize:(int)newInertia {
    
    if (allowsSpawning == NO) return nil;

    Asteroid *newAsteroid = [[Asteroid alloc] init];
    [[Asteroid sharedArray] addObject: newAsteroid];
	[newAsteroid release];

    int n;
    for (n=0;n<3;n++){
        newAsteroid->rotaxis[n] = [Randomness randomFloat: -1 max: 1];
    }
	newAsteroid->rotvel = [Randomness randomFloat: 0 max: 2];
	
    for (n=0;n<2;n++){
        newAsteroid->vel[n] = [Randomness randomFloat: 0 max: 5]-2.5;
    }

    newAsteroid->pos[2] = -(float)[Randomness randomFloat: 30 max: 300];
    newAsteroid->inertia= newInertia;
    newAsteroid->health = 2.0 * newInertia;
    
    //newAsteroid->maxspeed = 2.0f;
    [newAsteroid setCoordsRandomWall];
    return newAsteroid;

}

+(id)SpawnAtX:(float)x
    y:(float)y
    xvel:(float)xvel
    yvel:(float)yvel
    inertia:(float)newInertia {
    
     if (allowsSpawning == NO) return nil;
    
    Asteroid *newAsteroid = [[Asteroid alloc] init];
    [[Asteroid sharedArray] addObject: newAsteroid];
    [Asteroid release];
	
    newAsteroid->pos[0] = x;
    newAsteroid->pos[1] = y;
    
    int n;
    for (n=0;n<3;n++){
        newAsteroid->rotaxis[n] = [Randomness randomFloat: -1 max: 1];
    }
	newAsteroid->rotvel = [Randomness randomFloat: 0 max: 2];
    for (n=0;n<2;n++){
        newAsteroid->vel[n] = [Randomness randomFloat: 0 max: 3]-1.5;
    }

    newAsteroid->pos[2] = -(float)[Randomness randomFloat: 30 max: 300];
			
    newAsteroid->vel[0]=xvel;
    newAsteroid->vel[1]=yvel;
    
    newAsteroid->inertia= newInertia;
    newAsteroid->health = 2.0 * newInertia;
	
	return newAsteroid;

}

+(void)destroyAsteroid:(int)n rotation:(float)therot multx:(float)multx multy:(float)multy {
            
    Asteroid  *sel = [[Asteroid sharedArray] objectAtIndex: n];
    
    //[Particle spawnAtX:sel->pos[0] y: sel->pos[1] number: sel->inertia distance: 16];
    
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"Scored" object: [NSNumber numberWithInt: pow(sel->inertia,2)*25]];
    
    NSPoint theOrigin;
    theOrigin.x = sel->pos[0];
    theOrigin.y = sel->pos[1];
    
    [Particle spawnGroupAtPoint: theOrigin
        advance: [sel radius]
        number: (int)(sel->inertia)*10
        speed: 2.5
        expansion: 0.0
        fade: -(1.0/20)
        size: 10.0
        sprite: [Particle particle]];
                
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: 3.6
        fade: -(1.0/10) / sel->inertia
        size: [sel radius] * 2
        sprite: [Particle shock]];
        
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: -0.25 / sel->inertia
        fade: -(1.0/30)
        size: [sel radius] * 3
        sprite: [Particle starburst]];
    
    [Explosion SpawnAtX: sel->pos[0] y: sel->pos[1] scale: sel->inertia/4.0 rotation: 0 sprite: [Explosion ExplosionSprite]];
    
    int m;
    switch ( (int)sel->inertia ) {
    
    
        case HUGE_INERTIA: //HUGE asteroid
        
            for (m = 1; m<=2;m++) {
            
                NSPoint offsetOrigin = theOrigin;
                offsetOrigin.x += [Randomness randomFloat: 0 max: [sel radius]] - [sel radius]/2.0f;
                offsetOrigin.y += [Randomness randomFloat: 0 max: [sel radius]] - [sel radius]/2.0f;
        
                [Particle spawnAtPoint: offsetOrigin
                    rotation: [Randomness randomInt: 0 max: 360]
                    speed: .3
                    expansion: 0.5
                    fade: -(1.0/800)-[Randomness randomFloat: 0 max: 0.005]
                    size: [sel radius]*2
                    sprite: [Particle smoke]];
                
                [Crystal SpawnAtX: sel->pos[0] y: sel->pos[1] ];
                
                float randomfactor=(m*180);
                [[self class] SpawnAtX: sel->pos[0]+[Randomness randomInt: 0 max: 96]-48.0
                    y: sel->pos[1]+[Randomness randomInt: 0 max: 96]-48.0
                    xvel: sel->vel[0]+degreeCosine(randomfactor+therot)
                    yvel: sel->vel[1]+degreeSine(randomfactor+therot)
                    inertia:LARGE_INERTIA];
                    
                 [[self class] SpawnAtX: sel->pos[0]+[Randomness randomInt: 0 max: 96]-48.0
                    y: sel->pos[1]+[Randomness randomInt: 0 max: 96]-48.0
                    xvel: sel->vel[0]+degreeCosine(randomfactor+60+therot)*2
                    yvel: sel->vel[1]+degreeSine(randomfactor+60+therot)*2
                    inertia:MEDIUM_INERTIA];
                    
                [[self class] SpawnAtX: sel->pos[0]+[Randomness randomInt: 0 max: 96]-48.0
                    y: sel->pos[1]+[Randomness randomInt: 0 max: 96]-48.0
                    xvel: sel->vel[0]+degreeCosine(randomfactor+80+therot)*4
                    yvel: sel->vel[1]+degreeSine(randomfactor+80+therot)*4
                    inertia:MEDIUM_INERTIA];

            }
            break;
    
        case LARGE_INERTIA: //large asteroid
        
            for (m = 1; m<=3;m++) {
            
            
                NSPoint offsetOrigin = theOrigin;
                offsetOrigin.x += [Randomness randomFloat: 0 max: 10];
                offsetOrigin.y += [Randomness randomFloat: 0 max: 10];
        
                [Particle spawnAtPoint: offsetOrigin
                    rotation: [Randomness randomInt: 0 max: 360]
                    speed: 0
                    expansion: 0.8
                    fade: -(1.0/200)-[Randomness randomFloat: 0 max: 0.005]
                    size: [sel radius]*2
                    sprite: [Particle smoke]];

            
                if ([Randomness randomInt: 0 max: 5]==3) {
                    [Crystal SpawnAtX: sel->pos[0] y: sel->pos[1] ];
                }
                float randomfactor=(m*45)-45;
                [[self class] SpawnAtX: sel->pos[0]+(float)[Randomness randomFloat: 0 max: 48]-24.0
                    y: sel->pos[1]+(float)[Randomness randomFloat: 0 max: 48]-24.0
                    xvel: sel->vel[0]+degreeCosine(therot+randomfactor)*(multx/sel->inertia)
                    yvel: sel->vel[1]+degreeSine(therot+randomfactor)*(multy/sel->inertia)
                    inertia:MEDIUM_INERTIA];
            }
            break;
        
        case MEDIUM_INERTIA: //medium asteroid
            
            for (m = 1; m<=3;m++) {
                if ([Randomness randomInt: 0 max: 6]==5) {
                    [Crystal SpawnAtX: sel->pos[0] y: sel->pos[1] ];
                }
                float randomfactor=(m*45)-45;
                [[self class] SpawnAtX: sel->pos[0]+(float)[Randomness randomFloat: 0 max: 48]-24.0
                    y: sel->pos[1]+(float)[Randomness randomFloat: 0 max: 48]-24.0
                    xvel:sel->vel[0]+degreeCosine(therot+randomfactor)*(multx/sel->inertia)
                    yvel: sel->vel[1]+degreeSine(therot+randomfactor)*(multy/sel->inertia)
                    inertia:SMALL_INERTIA];
            }
            break;
    }
    
    [[Asteroid sharedArray] removeObjectAtIndex: n];
        
    if ([[Asteroid sharedArray] count] == 0){
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AllAsteroidsDestroyed" object: nil];
    
    }
}

+(void)spawnHuge {
    
     [[self class] SpawnOfSize: HUGE_INERTIA];
     
}

+(void)spawnLarge {
    
     [[self class] SpawnOfSize: LARGE_INERTIA];
    
}

+(void)setAllowsSpawning:(NSNumber *)value {

    allowsSpawning = [value intValue];

}

+(void)spawnMedium {

     [[self class] SpawnOfSize: MEDIUM_INERTIA];

}

+(void)spawnSmall {

    [[self class] SpawnOfSize: SMALL_INERTIA];
    
}

+(void)spawnRandomSize {

    int size = [Randomness randomInt: 0 max: 2];
    switch (size) {
    
        case 0:
            [[self class] spawnSmall];
            break;
        case 1:
            [[self class] spawnMedium];
            break;
        case 2:
            [[self class] spawnLarge];
            break;
        default:
            NSLog(@"Error, invalid asteroid size.");
            break;
    }

}

+(void)makeAll{
    
    int n;        
        
    for (n=0;n<[[Asteroid sharedArray] count];n++){

        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex: n];
        [sel retain];

		
        //Combine this with the two lines below
        sel->pos[0]+=sel->vel[0]*FRAME;
        sel->pos[1]+=sel->vel[1]*FRAME;

        [sel adjustSpeed];
        [sel checkShots];
        
        int m;
        for (m=0;m<[[Asteroid sharedArray] count];m++){
            
            if ([[Asteroid sharedArray] objectAtIndex:m] != sel){
            
                if ([sel collideWithObject: [[Asteroid sharedArray] objectAtIndex:m]]){
        
                    [sel doCollisionWithObject:[[Asteroid sharedArray] objectAtIndex:m]];
                    
                }
            }
        }

        
        if (sel->health <= 0) [[self class] destroyAsteroid: n
                                rotation: sel->lastHitRotation
                                multx: 4.2
                                multy: 4.2];

        [sel doLevelWrap];
        
        if ([sel isOnScreen]){ //only draw if asteroid is onscreen
        
			[sel draw];
		
		}
        [sel release];
    }
            
}

-(void)draw {

	glEnable(GL_LIGHTING);
	glEnable(GL_TEXTURE);
	glEnable(GL_NORMALIZE);

	glPushMatrix();
	
		glTranslatef(self->pos[0],self->pos[1],self->pos[2]);
				
		rot+=rotvel*FRAME;		
		glRotatef(rot,rotaxis[0], rotaxis[1], rotaxis[2]);				
		
		switch ((int)self->inertia) {
		
			case HUGE_INERTIA:
				[asteroidTexture2 bind];
				[hugeModel draw];
				break;
			case LARGE_INERTIA:
			    [asteroidTexture bind];
				[largeModel draw];
				break;
			case MEDIUM_INERTIA:
			    [asteroidTexture bind];
				[mediumModel draw];
				break;
			case SMALL_INERTIA:
			    [asteroidTexture bind];
				[smallModel draw];
				break;
		}
	glPopMatrix();

}

-(void)doRedTimeEffect {

    [super doRedTimeEffect];

}

-(void)setRedTime:(float)newRed {

    [super setRedTime: newRed];

}

-(void)checkShots {

    int i,j;
	
	NSArray *a = [[Shot sharedSet] allObjects];
	
    for (i=0;i<[a count];i++){
        
        Shot *sel = [a objectAtIndex: i];
        if ([self collideWithObject: sel] && sel->creator != self){
            health--;
            lastHitRotation = aDegreeTan2(sel->vel[1],sel->vel[0]);
            
            
            [self doCollisionWithObject: sel];
            //vel[0] += degreeCosine(lastHitRotation)*4 / inertia;
            //vel[1] += degreeSine(lastHitRotation)*4 / inertia;
            
            for (j=0;j<5;j++){
            
                NSPoint theOrigin;
                theOrigin.x = sel->pos[0];
                theOrigin.y = sel->pos[1];
            
                [Particle spawnAtPoint: theOrigin
                    rotation: [Randomness randomFloat: lastHitRotation-10 max: lastHitRotation+10]
                    speed: 2.5
                    expansion: 0.0
                    fade: -(1.0/20)
                    size: 10.0
                    sprite: [Particle particle]];
                
            }

            [[Shot sharedSet] removeObject: sel];
        }
    }      

}

- (void)encodeWithCoder:(NSCoder *)coder {
        
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeFloat:health forKey:@"health"];
        [coder encodeFloat:lastHitRotation forKey:@"lastHitRotation"];
                
    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&health];
        [coder encodeValueOfObjCType:@encode(float) at:&lastHitRotation];
        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
        
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        health =  [coder decodeFloatForKey:@"health"];
        lastHitRotation =  [coder decodeFloatForKey:@"lastHitRotation"];
        
    } else {
        
        [coder decodeValueOfObjCType:@encode(float) at:&health];
        [coder decodeValueOfObjCType:@encode(float) at:&lastHitRotation];

    }
    return self;
}

-(float)maxSpeed {
 
    return 2.0f;
    
}

-(float)radius {
 
    switch ((int)inertia) {
        
	case HUGE_INERTIA:
            return 138.0;            
        case LARGE_INERTIA:
            return 50.0;
        case MEDIUM_INERTIA:
            return 30.0;
        case SMALL_INERTIA:
            return 25.0;
    }
	
    NSLog(@"Asteroid error, coudl not find radius");
    return 0.0;
}

-(float)danger {
 
    switch((int)inertia){
    
    case HUGE_INERTIA:
        return 90;
    case LARGE_INERTIA:
        return 7;
    case MEDIUM_INERTIA:
        return 4;
    case SMALL_INERTIA:
        return 1;    
    }
    NSLog(@"Asteroid, coudl not find danger");
    return 0;
}

@end