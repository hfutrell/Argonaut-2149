//
//  Asteroid.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameObject.h"

@interface Asteroid : GameObject {

    float depth;
    
    @public
    
        float health;
        float lastHitRotation;
        
}

-(void)draw;

+(void)InitAssets;
+(id)sharedArray;
+(id)SpawnAtX:(float)x
    y:(float)y
    xvel:(float)xvel
    yvel:(float)yvel
    inertia:(float)inertia;
+(void)makeAll;
+(void)destroyAsteroid:(int)n rotation:(float)therot multx:(float)multx multy:(float)multy;
-(void)doRedTimeEffect;
-(void)setRedTime:(float)newRed;
-(void)checkShots;
+(id)SpawnOfSize:(int)newInertia;

//accessing model data
+(Model *)smallModel;
+(Model *)mediumModel;
+(Model *)largeModel;
+(Model *)hugeModel;
+(GLTexture *)asteroidTexture;
+(GLTexture *)asteroidTexture2;

+(void)setSharedArray:(NSArray *)newArray;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end