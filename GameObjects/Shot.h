//
//  Shot.h
//  Argonaut
//
//  Created by Holmes Futrell on Wed Jul 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameObject.h>
//#import "Randomness.h"
#import <Asteroid.h>
#import <GLSprite.h>
//#import "Ship.h"

@interface Shot : GameObject {


    @public
		float timeSinceAutoZap;
		float time;
        GameObject *creator;
		GLSprite *sprite;

}

void spawnShot(float x,float y,float rotation);

+(void)makeAll;

//+(void)SpawnAtX:(float)x y:(float) y rotation:(float)rotation;
+(id)sharedSet;
+(void)InitAssets;
+(Shot *)SpawnFrom:(GameObject *)master;
+(void)setSharedSet:(NSMutableSet *)newSet;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
