//
//  Pirate.h
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ship.h"

//ARRR Me matey's!  Pirates hate Argonauts!

@interface Pirate : Ship {

    float timeSinceLastPoof;
	float screenTime;
	GLSprite *sprite;
	
	int shotParity;

}
-(void)make;
+(void)InitAssets;
-(void)accelerate;

@end

@interface DreadPirate : Pirate {

}
@end