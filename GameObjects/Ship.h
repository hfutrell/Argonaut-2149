//
//  Ship.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Randomness.h"
#import "Model.h"
#import "FocoaMod.h"

//Some ships
//#import "GatherBot.h"

#define CONTROL_HUMAN 879
#define CONTROL_COMPUTER 880

NSPoint pointNormalize(NSPoint a);
NSPoint pointDiff(NSPoint a, NSPoint b);
float angleBetweenVectors(NSPoint a, NSPoint b);

/*This is our ship class.  All paceships in the game are derived from this class. */

@interface Ship : GameObject {

    float direction[2]; //danger vector
    float dest;
    float dangerMeter; //current level of danger
    float safestRotation,mostDangerousRotation;

	int score; //ships score
	int control; //decides whether or not to do AI, see listed control states above
    
    float timeBeforeShoot; //how long the ship has before it can shoot again
    float timeSinceAutoZap;
    float useItemTime;
    
    BOOL crystalMagnetOn;
	BOOL autoZapperOn;
    BOOL isAccelerating;
	
    //NSString *shipName;
    
    NSMutableDictionary *powerupsDictionary;
    
    @public
    
        float shields;
        int crystals;
        NSString *selectedPowerupName;
        int selectedPowerupIndex;
        float invincableTime;


}
+ (void)initAssets;
//getting the shared array in which all references to ships are kept
+ (id)sharedSet;
    //some class methods
+ (id)spawn;
+ (void)makeAll;
+(void)Destroy:(Ship *)sel;
+ (id)shipOfNetID:(unsigned int)netID;
-(NSPoint)directionVector;

//internal methods
-(float)shieldRechargeRate;
- (BOOL)autoZapperState;
- (float)useItemTime;
- (void)assessDanger;
- (void)compForX:(float)xpos y:(float)ypos;
- (float)findNearestCrystal;
- (BOOL)turnTowardsDest;
- (float)findNearestCrystal;
- (void)checkCrystals;
- (void)retreat;
- (void)checkAsteroids;
- (void)compensateForDangerOf:(GameObject *)sel x:(float)xpos y:(float)ypos;
- (void)make;
- (void)fireSuccess;
- (void)checkShots;
- (BOOL)aimedAtShipOfClass:(id)someClass speed:(float)speed tolerence:(float)tolerence distance:(BOOL)disflag;
- (id)findNearestShipOfClass:(id)someClass;
- (void)blowUp;
- (void)gatherPowerupOfType:(NSString *)type;
- (void)checkPowerupModules;
- (BOOL)accelerateTowardsDest;
- (id)findNearestAsteroid;
- (BOOL)aimedAtAsteroid;
- (BOOL)doPowerupEffectForType:(NSString *)type;
- (void)doCrystalMagnetEffect;
- (BOOL)doAutoZap;

//some accessors to various ship attributes
- (NSDictionary *)powerups;
- (float)shields;
- (float)maxShields;
- (unsigned int)crystals;
- (unsigned int)healthModules;
- (NSArray *)powerupsArray;
- (NSString *)selectedPowerupName;
- (int)selectedPowerupIndex;
- (BOOL)crystalMagnetState;
- (NSDictionary *)powerupsDictionary;
- (BOOL)canFire;
- (BOOL)canUsePowerup;
-(unsigned int)netID;

//setting various ship attributes
- (void)setShields:(float)_sheilds;
- (void)setCrystals:(unsigned int)crystals;
- (void)setPowerupsDictionary:(NSDictionary *)_powerupsDictionary;

//Ship movement
- (void)turnLeft;
- (void)turnRight;
- (void)accelerate;
- (void)fire;
- (void)applyBreaks;

//setting the control method of the ship
- (id)setControlHuman;
- (id)setControlComputer;
- (id)setControl:(unsigned int)netID;

//setting ship coordinates
- (void)setCoordsSafe;

//Selecting and using powerups
- (void)setSelectedPowerupIndex:(int)newIndex;
- (void)selectNextPowerup;
- (void)selectPreviousPowerup;
- (void)useSelectedItem;

//encoding and decoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

// predictive aiming
- (NSPoint)aimForTarget:(GameObject *)target projectileSpeed:(float)cv time:(float *)timeToTarget;

@end
