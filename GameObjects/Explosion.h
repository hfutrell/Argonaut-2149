//
//  Explosion.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface Explosion : GameObject {

    float scale,time;
    GLSprite *sprite;
    //FocoaMod *explosionSound;

}
+(id)sharedSet;
+(Explosion *)SpawnAtX:(float)x y:(float)y scale:(float)newScale rotation:(float)rotation sprite:(GLSprite *)newSprite;
+(void)makeAll;
+(void)InitAssets;

+(GLSprite *)TrailSprite;
+(GLSprite *)ExplosionSprite;
+(GLSprite *)DualSprite;

//making preset explosions
+(id)spawnSmallAtPoint:(NSPoint)theOrigin;
+(id)spawnMediumAtPoint:(NSPoint)theOrigin;
+(id)spawnLargeAtPoint:(NSPoint)theOrigin;
+(id)spawnHugeAtPoint:(NSPoint)theOrigin;



@end
