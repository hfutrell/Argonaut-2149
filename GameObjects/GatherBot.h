//
//  GatherBot.h
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameObject.h>
#import <Ship.h>

@class Crystal, Explosion;

@interface GatherBot : Ship {

}
-(void)make;
+(void)InitAssets;

-(void)accelerate;

@end
