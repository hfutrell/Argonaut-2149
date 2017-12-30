//
//  Argonaut.h
//  Argonaut
//
//  Created by Holmes Futrell on Thu Jul 31 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ship.h"


@interface Argonaut : Ship {

    float timeSinceLastPoof;
	int engineParity;
	int shotParity;
    
}
-(void)make;
+(void)initAssets;
-(void)accelerate;
-(float)reloadTime;

@end
