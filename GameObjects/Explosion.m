//
//  Explosion.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Explosion.h"
#import "Particle.h"

static NSMutableSet *sharedSet;
static GLSprite *explosionSprite,*trailSprite,*dualSprite;
static FocoaMod *explosionSound1,*explosionSound2;

@implementation Explosion

+(void)InitAssets {

    explosionSprite = [[[GLSprite alloc] initWithImages:@"data/sprites/explosion/exp" extension:@".jpg" frames: 15]setCoordMode:@"center"];
    trailSprite = [[[GLSprite alloc] initWithImages:@"data/sprites/trail/trail" extension:@".jpg" frames: 8] setCoordMode:@"center"];
    dualSprite = [[[GLSprite alloc] initWithImages:@"data/sprites/dual trail/dtrail" extension:@".jpg" frames: 5]setCoordMode:@"center"];
    explosionSound1 = [[FocoaMod alloc] initWithResource:@"data/sounds/Explosion01.mp3" mode:FSOUND_HW3D];
    [explosionSound1 setMinDistance: 200 maxDistance: 800];
    explosionSound2 = [[FocoaMod alloc] initWithResource:@"data/sounds/Explosion02.mp3" mode:FSOUND_HW3D];
    [explosionSound2 setMinDistance: 200 maxDistance: 1000];
    
}

+(void)deallocAssets {

    [explosionSprite release];
    [trailSprite release];
    [explosionSound1 release];
    [explosionSound2 release];
    [sharedSet release];
    sharedSet = nil;

}

+(id)sharedSet {
    return !sharedSet ? sharedSet = [NSMutableSet new] : sharedSet;
}


+(id)spawnMediumAtPoint:(NSPoint)theOrigin {

    [Particle spawnGroupAtPoint: theOrigin
        advance: 24
        number: (int)(2)*10
        speed: 2.5
        expansion: 0.0
        fade: -(1.0/20)
        size: 10.0
        sprite: [Particle particle]];
                
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: 3.6
        fade: -(1.0/10) / 2
        size: 24 * 2
        sprite: [Particle shock]];
        
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: -0.25 / 2
        fade: -(1.0/30)
        size: 24 * 3
        sprite: [Particle starburst]];
    
    return [Explosion SpawnAtX: theOrigin.x y: theOrigin.y scale: 2/4.0 rotation: 0 sprite: [Explosion ExplosionSprite]];

}

+(id)spawnLargeAtPoint:(NSPoint)theOrigin {

    [Particle spawnGroupAtPoint: theOrigin
        advance: 32
        number: (int)(4)*10
        speed: 2.5
        expansion: 0.0
        fade: -(1.0/20)
        size: 10.0
        sprite: [Particle particle]];
                
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: 3.6
        fade: -(1.0/10) / 4
        size: 32 * 2
        sprite: [Particle shock]];
        
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: -0.25 / 4
        fade: -(1.0/30)
        size: 32 * 3
        sprite: [Particle starburst]];
        
    [Particle spawnAtPoint: theOrigin
        rotation: [Randomness randomInt: 0 max: 360]
        speed: 0
        expansion: 0.8
        fade: -(1.0/200)-[Randomness randomFloat: 0 max: 0.005]
        size: 64
        sprite: [Particle smoke]];

    return [Explosion SpawnAtX: theOrigin.x y: theOrigin.y scale: 1 rotation: 0 sprite: [Explosion ExplosionSprite]];


}


//inertia 12
//radius 100

+(id)spawnHugeAtPoint:(NSPoint)theOrigin {
     
    [Particle spawnGroupAtPoint: theOrigin
        advance: 100
        number: (int)(12)*10
        speed: 2.5
        expansion: 0.0
        fade: -(1.0/20)
        size: 10.0
        sprite: [Particle particle]];
    
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: 3.6
        fade: -(1.0/10) / 12
        size: 100 * 2
        sprite: [Particle shock]];
    
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: -0.25 / 12
        fade: -(1.0/30)
        size: 100 * 3
        sprite: [Particle starburst]];
    
    int m;
    for (m = 1; m<=2;m++) {
        
        NSPoint offsetOrigin = theOrigin;
        offsetOrigin.x += [Randomness randomFloat: 0 max: 100*2]- 100;
        offsetOrigin.y += [Randomness randomFloat: 0 max: 100*2]- 100;
        
        [Particle spawnAtPoint: offsetOrigin
            rotation: [Randomness randomInt: 0 max: 360]
            speed: .3
            expansion: 0.5
            fade: -(1.0/800)-[Randomness randomFloat: 0 max: 0.005]
            size: 100*2
            sprite: [Particle smoke]];
        
    }
    
    return [Explosion SpawnAtX: theOrigin.x y: theOrigin.y scale: 3 rotation: 0 sprite: [Explosion ExplosionSprite]];
    
}

+(id)spawnSmallAtPoint:(NSPoint)theOrigin {

    [Particle spawnGroupAtPoint: theOrigin
        advance: 32
        number: 5
        speed: 1.5
        expansion: 0.0
        fade: -(1.0/15)
        size: 10.0
        sprite: [Particle particle]];
                    
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: 3.6
        fade: -(1.0/10)
        size:  40
        sprite: [Particle shock]];
            
    [Particle spawnAtPoint: theOrigin
        rotation: 0
        speed: 0
        expansion: -0.25
        fade: -(1.0/15)
        size: 48
        sprite: [Particle starburst]];
        
    return [Explosion SpawnAtX: theOrigin.x y: theOrigin.y scale: 0.25 rotation: 0 sprite: [Explosion ExplosionSprite]];

}

//Spawns an explosion at coordinate parameters
+(Explosion *)SpawnAtX:(float)x y:(float)y scale:(float)newScale rotation:(float)rotation sprite:(GLSprite *)newSprite {

    Explosion *newExplosion = [[Explosion alloc] init];

    newExplosion->pos[0]=x;
    newExplosion->pos[1]=y;
    newExplosion->time=0;
    newExplosion->scale = newScale;
    newExplosion->sprite = newSprite;
    newExplosion->rot = rotation;
    
    [[Explosion sharedSet] addObject: newExplosion];
   
   //make a sound if its an explosion, but not if its a trail from a spaceship!
    if (newSprite == explosionSprite){
          
        if (newScale > 1){
            
            [newExplosion fireSound: explosionSound2];
            [explosionSound2 setVolume: 255 * newScale];
            
        }
        else {
            [newExplosion fireSound: explosionSound1];
            [explosionSound1 setVolume: 255 * newScale];

        }

    }
    
	[newExplosion release];
	
    return newExplosion;

}

-(void)make{

        time += FRAME*0.5;
		pos[0] += vel[0] * FRAME;
		pos[1] += vel[1] * FRAME;
        if (time >= [sprite numFrames] ){
            [[Explosion sharedSet] removeObject: self];
            return;
        }
      
        if ([self isOnScreen]){
            glPushMatrix();
                                        
                glTranslatef(pos[0],pos[1],-80.0);
                glScalef(scale,scale,scale);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE);  
                glRotatef(rot,0,0,1); 
                [sprite drawFrame:(int)time];
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glPopMatrix();
        }

}

//Produces EXPLOSION effect on the screen
+(void)makeAll {

	NSArray *a = [[Explosion sharedSet] allObjects];
	int i;
	for (i=0; i<[a count]; i++) {
		Explosion *cur = (Explosion *)[a objectAtIndex: i];
		[cur make];
	}
    
}

+(GLSprite *)TrailSprite {
    return trailSprite;
}
+(GLSprite *)ExplosionSprite {
    return explosionSprite;
}
+(GLSprite *)DualSprite {
    return dualSprite;
}


@end
