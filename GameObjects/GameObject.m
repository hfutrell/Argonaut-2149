//
//  GameObject.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"
#import "Game.h"
#import "math.h"
#import "PreferenceController.h"

static float frameRate;
static float cameraPos[2];
static Game *game;

@implementation GameObject

+(void)setGame:(Game *)_game {
    game = _game;
}

+(Game *)game {
    if (!game) NSLog(@"Game is nil!");
    return game;
}

+(void)setCameraPosition:(float)xPos :(float)yPos {
    cameraPos[0] = xPos;
    cameraPos[1] = yPos;
}

-(BOOL)isOnScreen {
    if (abs(cameraPos[0]-pos[0])-[self radius] <= (horizontalResolution / 2.0f) && abs(cameraPos[1]-pos[1])-[self radius] <= (verticalResolution / 2.0f) ) return TRUE;
    return FALSE;
}

+(BOOL)pointOnScreen:(NSPoint)point {
  if (abs(cameraPos[0]-point.x) <= 400 && abs(cameraPos[1]-point.y) <= 300 ) return TRUE;
    return FALSE;
}

+(void)SetFrameRate:(float)newFrameRate{
    frameRate=newFrameRate;
}

+(float)FrameRate{
    return frameRate;
}

-(NSPoint)location {
	return NSMakePoint(pos[0], pos[1]);
}
-(NSPoint)velocity {
	return NSMakePoint(vel[0], vel[1]);
}

-(void)doLevelWrap {
    
    float wrapHeight = levelHeight / 2.0f;
    float wrapWidth = levelWidth / 2.0f;
    
    pos[0] = wrap(pos[0],cameraPos[0]-wrapWidth,cameraPos[0]+wrapWidth);
    pos[1] = wrap(pos[1],cameraPos[1]-wrapHeight,cameraPos[1]+wrapHeight);
        
}

float wrap(float valueGiven, float min, float max) {
    
    valueGiven = fmodf(valueGiven-min,max-min)+min;
    valueGiven = fmodf(valueGiven-max,min-max)+max;
    return valueGiven;

}

-(BOOL)collideWithObject:(GameObject *)object{

    return pow([self radius]+[object radius],2) > pow(pos[0]-object->pos[0],2)+pow(pos[1]-object->pos[1],2);

}

-(void)doCollisionWithObject:(GameObject *)object {
 
    float relativeVelocity[2];
    relativeVelocity[0] = vel[0] - object->vel[0];
    relativeVelocity[1] = vel[1] - object->vel[1];
    
    float relativeSpeed = sqrt( pow( relativeVelocity[0] , 2) + pow (relativeVelocity[1],2) );
    
    float coordinateDifference[2];
    coordinateDifference[0] = pos[0] - object->pos[0];
    coordinateDifference[1] = pos[1] - object->pos[1];
    
    float theta = atan2( coordinateDifference[1], coordinateDifference[0] );
        
    theta = atan2( coordinateDifference[1], coordinateDifference[0] );
    
    float inertiaOfSystem = inertia + object->inertia;
    float centerOfGravityVel[2];
        
    centerOfGravityVel[0] = ( (vel[0] * inertia) + (object->vel[0] * object->inertia) ) / inertiaOfSystem;
    centerOfGravityVel[1] = ( (vel[1]  * inertia) + (object->vel[1] * object->inertia) ) / inertiaOfSystem;
    
    vel[0] = (cos( theta ) * relativeSpeed) * (object->inertia/inertiaOfSystem);
    vel[1] = (sin( theta ) * relativeSpeed) * (object->inertia/inertiaOfSystem);
   
    object->vel[0] = -(cos( theta ) * relativeSpeed) * (inertia/inertiaOfSystem);
    object->vel[1] = -(sin( theta ) * relativeSpeed) * (inertia/inertiaOfSystem);

    vel[0] += centerOfGravityVel[0];// * (inertia/inertiaOfSystem);
    vel[1] += centerOfGravityVel[1];// * (inertia/inertiaOfSystem);
    
    object->vel[0] += centerOfGravityVel[0];///*(object->inertia/inertiaOfSystem);
    object->vel[1] += centerOfGravityVel[1];//*(object->inertia/inertiaOfSystem);
    
}

BOOL sphereCollision(float x1, float y1, float r1, float x2, float y2, float r2) {

    return pow(r1+r2,2) > pow(x1-x2,2)+pow(y1-y2,2) ? TRUE : FALSE;

} 

-(float)distanceToObject:(GameObject *)object {

    return sqrt(pow( pos[0]-object->pos[0],2)+pow( pos[1]-object->pos[1],2))-[self radius]-[object radius];

}

//keeps the object moving in the same direction, but lowers the speed of the object to max speed
-(void)adjustSpeed{
    
    float speed = [self speed];
    if (speed > [self maxSpeed]) {
        vel[0] /= (speed/[self maxSpeed]);
        vel[1] /= (speed/[self maxSpeed]);
    }

}

-(float)speed {
    return sqrt(pow(vel[0],2)+pow(vel[1],2));
}

-(void)doRedTimeEffect{

    glColor4f((10.0-redTime)/10.0, (10.0-redTime)/10.0, 1.0 ,1.0);
    redTime-=FRAME;
    
}


-(void)setLocation:(NSPoint)p {
	pos[0] = p.x;
	pos[1] = p.y;
}	

-(void)setRedTime:(float)newRedTime {

    redTime=newRedTime;

}

-(void)setCoordsRandomWall {

    //int wall = (int)[Randomness randomFloat: 0 max: 3];
    
    float degrees = [Randomness randomFloat: 0 max: 360];
    
    pos[0] = cameraPos[0] + degreeCosine(degrees)*levelWidth / 2;
    pos[1] = cameraPos[1] + degreeSine(degrees)*levelWidth / 2;
    
    rot = degrees+180;
    //vel[0] = degreeCosine(degrees+180)*[self maxSpeed];
    //vel[1] = degreeSine(degrees+180)*[self maxSpeed];

}

//some constants
-(float)radius {
    return 0;
}
-(float)acceleration {
    return 0;
}
-(float)danger {
    return 0;
}
-(float)turningSpeed {
    return 0;
}
-(float)maxSpeed {
    return 0;
}

-(float)xPosition {
    return pos[0];
}

-(float)yPosition {
    return pos[1];
}

-(float)xVelocity {
    return vel[0];
}

-(float)yVelocity {
    return vel[1];
}

-(NSPoint)NSPointPosRep {
    return NSMakePoint(pos[0],pos[1]);
}

-(void)setToListeningPoint {

    [FocoaMod setListenerXPos: pos[0]
        yPos: pos[1]
        zPos: 0.0
        xVel: vel[0]//*60
        yVel: vel[1]//*60
        zVel: 0.0
        rotation: 90];

}

-(void)fireSound:(FocoaMod *)sound {

   [sound playExtendedWithXpos:pos[0]
        yPos:pos[1]
        zPos:0
        xvel:vel[0]//*60
        yvel:vel[1]//*60
        zvel:0.0];

}

-(void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [super dealloc];

}

+(void)deallocAssets {

    game = nil;
    
}

- (void)encodeWithCoder:(NSCoder *)coder {
        
    if ( [coder allowsKeyedCoding] ) {
                        
        [coder encodeFloat:pos[0] forKey:@"pos0"];
        [coder encodeFloat:pos[1] forKey:@"pos1"];
        [coder encodeFloat:pos[2] forKey:@"pos2"];
        [coder encodeFloat:vel[0] forKey:@"vel0"];
        [coder encodeFloat:vel[1] forKey:@"vel1"];
        [coder encodeFloat:rot forKey:@"rot"];
        [coder encodeFloat:rotvel forKey:@"rotvel"];
        [coder encodeFloat:inertia forKey:@"inertia"];

    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&pos[0]];
        [coder encodeValueOfObjCType:@encode(float) at:&pos[1]];
        [coder encodeValueOfObjCType:@encode(float) at:&pos[2]];
        [coder encodeValueOfObjCType:@encode(float) at:&vel[0]];
        [coder encodeValueOfObjCType:@encode(float) at:&vel[1]];
        [coder encodeValueOfObjCType:@encode(float) at:&rot];
        [coder encodeValueOfObjCType:@encode(float) at:&rotvel];
        [coder encodeValueOfObjCType:@encode(float) at:&inertia];
                
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
        
    if ( [coder allowsKeyedCoding] ) {
                
        // Can decode keys in any order
        pos[0] =  [coder decodeFloatForKey:@"pos0"];
        pos[1] =  [coder decodeFloatForKey:@"pos1"];
        pos[2] =  [coder decodeFloatForKey:@"pos2"];
        vel[0] =  [coder decodeFloatForKey:@"vel0"];
        vel[1] =  [coder decodeFloatForKey:@"vel1"];
        rot =  [coder decodeFloatForKey:@"rot"];
        rotvel =  [coder decodeFloatForKey:@"rotvel"];
        inertia = [coder decodeFloatForKey:@"inertia"];
                
    } else {

        [coder decodeValueOfObjCType:@encode(float) at:&pos[0]];
        [coder decodeValueOfObjCType:@encode(float) at:&pos[1]];
        [coder decodeValueOfObjCType:@encode(float) at:&pos[2]];
        [coder decodeValueOfObjCType:@encode(float) at:&vel[0]];
        [coder decodeValueOfObjCType:@encode(float) at:&vel[1]];
        [coder decodeValueOfObjCType:@encode(float) at:&rot];
        [coder decodeValueOfObjCType:@encode(float) at:&rot];
        [coder decodeValueOfObjCType:@encode(float) at:&inertia];
    
    }
    return self;
}


@end
