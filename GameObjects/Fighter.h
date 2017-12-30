//
//  Fighter.h
//  Argonaut
//
//  Created by Holmes Futrell on Tue Nov 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ship.h"

//ARRR Me matey's!  Pirates hate Argonauts!

@interface Fighter : Ship {
    
    float timeSinceLastPoof;
    
}
-(void)make;
+(void)initAssets;
-(void)accelerate;

@end
