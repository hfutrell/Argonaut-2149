//
//  GameObject.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GameView.h"
#import "GLSprite.h"
#import "Randomness.h"
#import "GLTexture.h"
#import "Model.h"
#import "FocoaMod.h"

#define degreeSine(x) sin((x)*(pi/180.0f))
#define degreeCosine(x) cos((x)*(pi/180.0f))
#define aDegreeCosine(x) (acos(side)*(180.0f/pi))
#define aDegreeSine(x) (asin(side)*(180.0f/pi))
#define aDegreeTan2(y,x) (atan2(y,x)*(180.0f/pi))

#define GAME [GameObject game]
#define FRAME [GameObject FrameRate]

#define levelWidth 2400
#define levelHeight 1800

@class Game;

//This is the top of the hierarchy for in game objects (crystals, asteroids, ships, ect)
@interface GameObject : NSObject {

    float redTime;
    
    @public
        
        float pos[3]; //short for position
        float vel[2]; //short for velocity
        float rotaxis[3]; //short for rotational velocity
		float rotvel;
		float rot;
        float inertia;//resitance to motion (mass), also used for radar size
        
}

float wrap(float valueGiven, float min, float max);
BOOL sphereCollision(float x1, float y1, float r1, float x2, float y2, float r2);

//collision detection with any other object descended from the GameObject class.
-(void)setLocation:(NSPoint)p;
-(BOOL)collideWithObject:(GameObject *)object;
-(void)adjustSpeed;
-(void)doLevelWrap;
-(void)doRedTimeEffect;
-(void)setRedTime:(float)newRedTime;
-(void)setCoordsRandomWall;
+(void)SetFrameRate:(float)newFrameRate;
+(float)FrameRate;
+(void)deallocAssets;
+(void)setGame:(Game *)game;
+(Game *)game;
//coordinates in space
-(float)xPosition;
-(float)yPosition;
-(float)xVelocity;
-(float)yVelocity;
-(float)speed;

//some constants
-(float)radius;
-(float)acceleration;
-(float)danger;
-(float)turningSpeed;
-(float)maxSpeed;

-(NSPoint)location;
-(NSPoint)velocity;

//represents the ships coordinates as an NSPoint
-(NSPoint)NSPointPosRep;

//tells us if the object's coordinates and size make it on camera
-(BOOL)isOnScreen;

//sets the object to FMOD's camera point
-(void)setToListeningPoint;
//fires sound from objects points with object's velocity
-(void)fireSound:(FocoaMod *)sound;
//-(void)setCoordsViewingEdge;

//Is this point visible by the camera?
+(BOOL)pointOnScreen:(NSPoint)point;
-(float)distanceToObject:(GameObject *)object;
+(void)setCameraPosition:(float)xPos :(float)yPos;

//uses some newtonian physics to get the results of a collision between two objects
-(void)doCollisionWithObject:(GameObject *)object;

//We need to be able to be incoded to be sent across the net
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end