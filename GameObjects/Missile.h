//
//  Missile.h
//  Argonaut
//
//  Created by Holmes Futrell on Sat Oct 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ship.h>

@interface Missile : Ship {
    
    float timeSinceSmokePuff;
    float timeSinceEnginePuff;
    Ship *owner;
    
    @public
    
        float maxDamage;
        float minRange;
        float maxRange;
        float timeTillExplosion;
        float startingTime;
        float warningInterval;
        float timeTillWarning;
    
}
//initialization of class
+(void)initAssets;
+(void)deallocAssets;
-(void)make;
+(id)spawnFromObject:(Ship *)master type:(id)theclass;
-(void)checkShipCollision;
//computational functions
-(float)damageForDistance:(float)distance;

//NSCoding protocol
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;


@end

@interface DumbMissile : Missile {
}
@end

@interface Nuke : Missile {
}

@end
