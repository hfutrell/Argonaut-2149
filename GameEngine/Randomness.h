//
//  Randomness.h
//  OpenGL Fun
//
//  Created by Holmes Futrell on Wed Feb 05 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <time.h>

@interface Randomness : NSObject {

}
+(void)initRNG;
+(int)randomInt:(int) min max:(int)max;
+(BOOL)randomBool;
+(float)randomFloat:(float) min max:(float)max;
@end
