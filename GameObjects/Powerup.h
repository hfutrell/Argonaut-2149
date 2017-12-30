//
//  Powerup.h
//  Argonaut
//
//  Created by Holmes on Mon Sep 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameObject.h"

@interface Powerup : GameObject {

@public

    int drawID;
    float timeLeft;
    NSString *type;
    
}

+(id)spawnAtPoint:(NSPoint)theOrigin type:(NSString *)_type;
+(id)spawn;
+(id)sharedSet;
+(void)makeAll;
+(void)initAssets;
-(void)destroy;
+(void)drawModelOfID:(int)model;
+(int)drawIDForType:(NSString *)type;

//NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
-(void)make;

@end
