//
//  Crystal.h
//  Argonaut
//
//  Created by Holmes Futrell on Sat Jul 19 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameObject.h"

@interface Crystal : GameObject {

    float time;

}

+(id)SpawnAtX:(float)x y:(float)y;
+(id)sharedSet;
+(void)makeAll;
+(void)InitAssets;
-(void)destroy;
-(void)make;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

+(void)setSharedSet:(NSMutableSet *)newSet;

@end
