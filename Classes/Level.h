//
//  Level.h
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 01 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

/* Level is an abstract object, but an object none the less.  It reads data from level files to set up level variables, object like planets and moons, and triggers which are set off by conditions such as booleon functions, and timers.  This is a HEFTY class as it must interface with my own scripting language HolmesTalk™*/

#import <Foundation/Foundation.h>
#import "Asteroid.h"
#import "Randomness.h"
#import "Crystal.h"
#import "Pirate.h"
#import "GatherBot.h"

@interface Level : NSObject {

    NSMutableDictionary *variableDictionary;
    //FILE *filein;
    float timeTillNextLine;
    int nextMusic;
    NSMutableArray *levelStrings;
    int currentLine;

}
+(id)levelOfName:(NSString *)resource;
+(id)levelOfNumber:(int)number;
-(id)buildLevelOfNumber:(int)number;
-(Level *)loadDataWithURL:(NSURL *)url;

-(void)maybeSpawnPirate;
-(void)maybeSpawnGatherBot;

-(IBAction)parseLine:(id)sender;
-(void)doLine:(NSString *)line;

-(id)buildClass:(char *)string;
-(SEL)buildSelector:(char *)string;

-(void)beatLevel;

+(NSArray *)levelsArray;
-(void)nextLine;
-(void)make:(float)timeGoneBy;
-(void)fadeMusic;


@end
