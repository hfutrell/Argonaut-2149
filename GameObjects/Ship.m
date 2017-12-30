//
//  Ship.m
//  Argonaut
//
//  Created by Holmes Futrell on Sat Jul 19 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import "Ship.h"
#import <Powerup.h>
#import <Asteroid.h>
#import <Crystal.h>
#import <Shot.h>
#import <Explosion.h>
#import <Missile.h>
#import "Game.h"

static NSMutableArray *sharedSet;

static FocoaMod *gatheredCrystalSound,*gatheredPowerupSound,*activateSound,*deactivateSound;

static BOOL needsDataResend = YES;
static FocoaMod *shootSound;
static GLSprite *glob;

@implementation Ship

+(id)sharedSet {
    return !sharedSet ? sharedSet = [[NSMutableSet alloc] init] : sharedSet;
}

+ (id)shipOfNetID:(unsigned int)netID { 
        
    NSEnumerator *enumerator = [[Ship sharedSet] objectEnumerator];
    Ship *sel;
    while(sel = [enumerator nextObject]) {
        if ([sel netID]==netID) return sel;
    }    
    return nil;
}

-(unsigned int)netID {
 
    return control;
    
}

//makes a new ship object and adds it to the shared array
//after that point it can be referenced by calling up the shared array
+(id)spawn {
    
    Ship *newShip = [[[self class] alloc] init];    
    [[Ship sharedSet] addObject: newShip ];
    newShip->crystals = 0;
    //newShip->healthModules = 0;
    newShip->powerupsDictionary = [NSMutableDictionary new];
    newShip->selectedPowerupName = @"none selected";
    newShip->selectedPowerupIndex = 0;
    
	[newShip release];
	
    needsDataResend = YES;
    return newShip;

}

//For a safe spawn, keep moving the object untill you find someplace where
//the danger is fairly low.
//This will be a spot with enough time to avoid any asteroids that may
//be near you when you spawn
-(void)setCoordsSafe {

    [self setCoordsRandomWall];
    [self assessDanger];
	int maxitr = 20;
	int itr = 0;
    while (dangerMeter > 0.00005){
        [self setCoordsRandomWall];
        [self assessDanger];
		itr++;
		if (itr >= maxitr) break;
    }
    needsDataResend = YES;
}

+(void)initAssets {
 
    gatheredCrystalSound=[[FocoaMod alloc]initWithResource:@"data/sounds/gatheredCrystal.wav" mode:FSOUND_2D];
    gatheredPowerupSound=[[FocoaMod alloc] initWithResource:@"data/sounds/gatheredPowerup.wav" mode:FSOUND_2D];
    activateSound = [[FocoaMod alloc] initWithResource:@"data/sounds/activate.wav" mode:FSOUND_2D];
    deactivateSound = [[FocoaMod alloc] initWithResource:@"data/sounds/deactivate.wav" mode:FSOUND_2D];
	shootSound = [[FocoaMod alloc] initWithResource:@"data/sounds/plasma_blast.wav" mode: FSOUND_HW3D];
	glob = [[GLSprite alloc] initWithSingleImage:@"data/sprites/glob" extension:@".png"];
	
}

+(void)deallocAssets {

    [sharedSet removeAllObjects];
    [sharedSet release];
	//[shootSound release];
	//[glob release];
    sharedSet = nil;
    if (gatheredCrystalSound && gatheredPowerupSound && activateSound && deactivateSound){
        [gatheredCrystalSound release];
        [gatheredPowerupSound release];
        [activateSound release];
        [deactivateSound release];
        gatheredCrystalSound=gatheredPowerupSound=activateSound=deactivateSound=nil;
    }
}

+(void)makeAll {

    glPushMatrix();

    int n=0;
    
	NSArray *a = [[Ship sharedSet] allObjects];
	
    NSEnumerator *enumerator = [a objectEnumerator];
    n=0;
    Ship *sel;
    while(sel = [enumerator nextObject])
    {
        if (!sel) continue;
        //[sel setMyIndex: n];
        [sel make];
        n++;
    }
    
    n=0;
    enumerator = [a objectEnumerator];
    while(sel = [enumerator nextObject])
    {
        if (!sel) continue;
        if (sel->shields <= 0){
            [Ship Destroy: sel];
        }
        n++;
    }
    glColor4f(1.0,1.0,1.0,1.0);
    
    glPopMatrix();
    
}

-(void)retreat {

    //mode = MODE_RETREAT;

}

-(void)dealloc {
    [super dealloc];
    [powerupsDictionary release];
}

-(void)assessDanger {
    
    dangerMeter=0;
    
    direction[0]=0;
    direction[1]=0;
                
    float imaginaryx = pos[0];
    float imaginaryy = pos[1];

    [self compForX: imaginaryx y: imaginaryy];
    
    //if (mode != MODE_RETREAT  && AIMode != AI_ADVANCED) {
    
    /*
    
        float magnitudeOfDanger = 1.0 / pow(800-pos[0],2);        
        float distanceSquared = pow(800-pos[0],2);
        direction[0] += ((imaginaryx - 800)/distanceSquared)*magnitudeOfDanger;
        dangerMeter+=magnitudeOfDanger;
    
        magnitudeOfDanger = 1.0 / pow(-pos[0],2);        
        distanceSquared = pow(-pos[0],2);
        direction[0] += ((imaginaryx)/distanceSquared)*magnitudeOfDanger;
        dangerMeter+=magnitudeOfDanger;
        
        magnitudeOfDanger = 1.0 / pow(600-pos[1],2);        
        distanceSquared = pow(600-pos[1],2);
        direction[1] += ((imaginaryy - 600)/distanceSquared)*magnitudeOfDanger;
        dangerMeter+=magnitudeOfDanger;
        
        magnitudeOfDanger = 1.0 / pow(-pos[1],2);        
        distanceSquared = pow(-pos[1],2);
        direction[1] += ((imaginaryy)/distanceSquared)*magnitudeOfDanger;
        dangerMeter+=magnitudeOfDanger;

    //}
    
    */
    
    //else {
        
        //computes wrap for advanced AI mode
        //[self compForX: imaginaryx+800 y: imaginaryy+600];
        //[self compForX: imaginaryx+800 y: imaginaryy];
        //[self compForX: imaginaryx+800 y: imaginaryy-600];
        //[self compForX: imaginaryx y: imaginaryy+600];
        //[self compForX: imaginaryx y: imaginaryy-600];
        //[self compForX: imaginaryx-800 y: imaginaryy+600];
        //[self compForX: imaginaryx-800 y: imaginaryy];
        //[self compForX: imaginaryx-800 y: imaginaryy-600];
    //}
    
    safestRotation = aDegreeTan2( direction[1],direction[0] );
    mostDangerousRotation = safestRotation+180;

}

-(void)compForX:(float)xpos y:(float)ypos{

    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex:i];
        [self compensateForDangerOf: sel x:xpos y:ypos];
    }
    
    Crystal *sel;
    NSEnumerator *enumerator = [[Crystal sharedSet] objectEnumerator];
    while(sel = [enumerator nextObject])
    {
        [self compensateForDangerOf: sel x:xpos y:ypos];
    }
    
	NSArray * a= [[Ship sharedSet] allObjects];
	
    for (i=0;i<[a count];i++){
    
        Ship *sel = [a objectAtIndex:i];
        if (sel != self){
            [self compensateForDangerOf: sel x:xpos y:ypos];
        }
    }
    
	//a= [[Shot sharedSet] allObjects];
	
    //for (i=0;i<[a count];i++){
    //    Shot *sel = [a objectAtIndex:i];
   //     [self compensateForDangerOf: sel x:xpos y:ypos];
   // }
}

-(void)compensateForDangerOf:(GameObject *)sel x:(float)xpos y:(float)ypos {

    //the magnitude of the danger presented by an asteroid follows an inverse square relationship
    float distance = sqrt(pow(xpos - sel->pos[0], 2) + pow(ypos - sel->pos[1],2));
	distance -= [sel radius] + [self radius];
									
	float magnitudeOfDanger = 1.0 / (distance*distance);        
    
    direction[0] += ((xpos - sel->pos[0])/(distance*distance))*magnitudeOfDanger*[sel danger];
    direction[1] += ((ypos - sel->pos[1])/(distance*distance))*magnitudeOfDanger*[sel danger];
    
    dangerMeter += magnitudeOfDanger;

}

-(BOOL)accelerateTowardsDest {

    BOOL result = [self turnTowardsDest];
    //rot = fmod(rot,360.0);
    if(fabs(rot-dest) < 60) { //if rotation is good, then accelerate
        [self accelerate];
    }
    return result;
}

//returns whether or not the ship is done turning or not
-(BOOL)turnTowardsDest {

	
	NSPoint destVector = NSMakePoint(cos(dest * pi / 180.0f), sin(dest * pi / 180.0f));

	NSPoint basis1 = NSMakePoint(cos(rot * pi / 180.0f), sin(rot * pi / 180.0f));
	NSPoint basis2 = NSMakePoint(-sin(rot * pi / 180.0f), cos(rot * pi / 180.0f));

	NSPoint destBasis = NSMakePoint(destVector.x * basis1.x + destVector.y * basis1.y , \
		destVector.x * basis2.x + destVector.y * basis2.y);
	
	float angle = atan2(destBasis.y, destBasis.x) * 180.0f / pi;

	if ([self turningSpeed]*FRAME < fabs(angle)) {

		if (angle < 0) {
			[self turnRight];
			return NO;
		}
		else if (angle > 0) {
			[self turnLeft];
			return NO;
		}
	
	}
	else {
		rot = dest;
	}	
	
    return YES;
}

/*-(float)findNearestWall {

    float distance = 800-pos[0];
    float tempDest = 0;
    if (pos[0] < distance) {
        distance = pos[0];
        tempDest = 180;
    }
    if (600-pos[1] < distance) {
        distance = 600-pos[1];
        tempDest = 270;
    }
    if (pos[1] < distance) {
        distance = pos[1];
        tempDest = 0;
    }
    return tempDest;
} */

//finds a rotation opposite to a ships velocity
-(float)findBreakingDest {

    return aDegreeTan2( vel[1], vel[0] )+180;

}

//turns towards breaking dest and applies thrusters
-(void)applyBreaks {

    //only break if the player is moving at a decent speed
    if ( pow(vel[0],2)+pow(vel[1],2) > 0.01 ) {

        //fint the breaking rotation and turn towards it
        dest = [self findBreakingDest];
        
        //if you are oriented correcly (opposite of your velocity), accelerate
        if ([self turnTowardsDest]){
            [self accelerate];
        }
    
    }

}

-(float)findNearestCrystal {

    float closestDistance = 10000000.0;

    Crystal *closestCrystal=nil;
    Crystal *sel;
    NSEnumerator *enumerator = [[Crystal sharedSet] objectEnumerator];
    while(sel = [enumerator nextObject])
    {
        //we just need to figure out which one is the closest.  Actual distance doesn't matter so we'll use the distance squared instead to avoid using sqrt();
        float distanceSquared = pow(pos[0]-sel->pos[0],2)+pow( pos[1]-sel->pos[1],2);
        if (distanceSquared < closestDistance){
            closestDistance = distanceSquared;
            closestCrystal = sel;
        }
    }
    if (closestDistance < 10000000.0){
        return aDegreeTan2( pos[1]-closestCrystal->pos[1],pos[0]-closestCrystal->pos[0])+180;
    }
    return 0.0f;

}

-(BOOL)canFire {
    if (timeBeforeShoot <= 0) return YES;
    return NO;
}

-(BOOL)canUsePowerup {
    if (useItemTime <= 0) return YES;
    return NO;
}

-(id)findNearestAsteroid {

    float closestDistance = 10000000.0;

    Asteroid *closestAsteroid = nil;

    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
    
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex: i];
    
        //we just need to figure out which one is the closest.  Actual distance doesn't matter so we'll use the distance squared instead to avoid using sqrt();
        float distanceSquared = pow(pos[0]-sel->pos[0],2)+pow( pos[1]-sel->pos[1],2);
        if (distanceSquared < closestDistance){
            closestDistance = distanceSquared;
            closestAsteroid = sel;
        }
    }
	return closestAsteroid;

}


-(void)setShields:(float)_sheilds{
    shields = _sheilds;
}
//-(void)setMaxShields:(float)_maxShields{
//    maxShields = _maxShields;
//}
-(void)setCrystals:(unsigned int)_crystals {
    crystals = _crystals;
}


-(NSString *)selectedPowerupName {
 
    return selectedPowerupName;
    
}

-(id)findNearestShipOfClass:(id)someClass {

    GameObject *closestAsteroid = nil;
	float closestDistance;
	
	NSArray *a = [[Ship sharedSet] allObjects];
	
    int i;
    for (i=0;i<[a count];i++){
    
        GameObject *sel = [a objectAtIndex: i];
    
        if ([sel isKindOfClass:[someClass class]] || !someClass){
    
            //we just need to figure out which one is the closest.  Actual distance doesn't matter so we'll use the distance squared instead to avoid using sqrt();
            float distanceSquared = pow(pos[0]-sel->pos[0],2)+pow( pos[1]-sel->pos[1],2);
            if (closestAsteroid == nil || distanceSquared < closestDistance){
                closestDistance = distanceSquared;
                closestAsteroid = sel;
            }
        
        }
    }
    
	return closestAsteroid;
}


-(void)checkCrystals {
	
	NSArray *a = [[Crystal sharedSet] allObjects];
	
	int i;
	for (i=0; i<[a count]; i++) 
    {        
	
		Crystal *sel = (Crystal *)[a objectAtIndex:i];
        if ([sel collideWithObject: self]){
            if (control != CONTROL_COMPUTER) [sel fireSound: gatheredCrystalSound];
			[[Crystal sharedSet] removeObject: sel];
            crystals++;
        }
    }
}

-(void)checkPowerupModules {

	NSArray *a = [[Powerup sharedSet] allObjects];
	int i;
	for (i=0; i<[a count]; i++)
    {     
		Powerup *sel = (Powerup *)[a objectAtIndex: i];
        if ([sel collideWithObject: self]){
            [[Powerup sharedSet] removeObject: sel];
			[self gatherPowerupOfType: (NSString *)sel->type];
        }
    }
}

-(void)gatherPowerupOfType:(NSString *)type {

    if (control != CONTROL_COMPUTER) [self fireSound: gatheredPowerupSound];
    
    if ([type isEqual:@"Shield Charge"]){
        shields+=2;
        if (shields > [self maxShields]) shields = [self maxShields];
        return;
    }
    else {
        //NSLog(@"Gathered %@",type);
        if ([powerupsDictionary objectForKey: type]){
            int numberLeft =  [[powerupsDictionary objectForKey: type] intValue];
            [powerupsDictionary setObject: [NSNumber numberWithInt: numberLeft+1] forKey: type];
        }
        else {
            [powerupsDictionary setObject: [NSNumber numberWithInt: 1] forKey: type];
        }
        [self selectedPowerupIndex];//refresh the selected (in case this changed things)
    }
    needsDataResend = YES;
}

-(void)checkAsteroids {

    int i;
    for (i=0;i<[[Asteroid sharedArray] count];i++){
    
        Asteroid *sel = [[Asteroid sharedArray] objectAtIndex: i];
        if ([self collideWithObject: sel]){
            
            //[self doCollisionWithObject: sel];
            float damage=(float)sel->inertia;
            sel->health-=shields;
            shields-=damage;
            sel->lastHitRotation = aDegreeTan2( sel->pos[1]-pos[1],sel->pos[0]-pos[0]);
            needsDataResend = YES;

            //[Asteroid destroyAsteroid: i
            //    rotation: aDegreeTan2(vel[1],vel[0])
            //    multx: vel[0]*sel->inertia
            //    multy: vel[1]*sel->inertia];
                 
            //[self setRedTime: 10];                                      
        }
    }
}

NSPoint pointNormalize(NSPoint a) {
	float length = sqrt(a.x*a.x + a.y*a.y);
	return NSMakePoint(a.x / length, a.y / length);
}

NSPoint pointDiff(NSPoint a, NSPoint b) {
	return NSMakePoint(a.x - b.x, a.y - b.y);
}

// predictive aiming
- (NSPoint)aimForTarget:(GameObject *)target projectileSpeed:(float)cv time:(float *)timeToTarget {

	//NSPoint p = [self location];// self
	//NSPoint q = [target location];// target
	NSPoint qv = pointDiff([target velocity],[self velocity]);// target velocity
	
	NSPoint d = pointDiff([target location], [self location]);//distance between target and turret
	
	// solve a nice quadratic equation
	float a = pow(qv.x,2) + pow(qv.y,2) - pow(cv,2);
	float b = 2.0*(d.x*qv.x + d.y*qv.y);
	float c = pow(d.x,2) + pow(d.y,2);
	float rational = pow(b,2) - 4.0*a*c;

	// if we can't hit 'em anyway
	if (rational < 0) {
		return pointNormalize(pointDiff([target location], [self location]));
	}

	float t = (-b - sqrt(rational)) / (2*a);// predicted time before collision

	//float maxTime = 600 / cv;
	//if (t > maxTime) t = maxTime;

	NSPoint qvt = NSMakePoint(qv.x * t,qv.y * t);
	NSPoint aimVector = NSMakePoint(d.x + qvt.x, d.y + qvt.y);
	
	if (timeToTarget != nil)
		*timeToTarget = t;
	
	return pointNormalize(aimVector);
		
}

float crossProduct(NSPoint a, NSPoint b) {
	return a.x*b.y - b.x*a.y;
}

float angleBetweenVectors(NSPoint a, NSPoint b) {
	a = pointNormalize(a);
	b = pointNormalize(b);
	float sinangle = crossProduct(a,b);
	if (a.x*b.x + a.y*b.y > 0) {
		return (180.0 / pi) * asin(sinangle);
	}
	else {
		return 180.0 - (180.0 / pi) * asin(sinangle);
	}
}

-(NSPoint)directionVector {
	return NSMakePoint( cos(rot * pi / 180.0), sin(rot * pi / 180.0));
}

//this will tell you if the ship is aimed at any member of a class someClass.
//someclass must be a subclass of Ship object.
//if someclass is nil, any class that is a subclass of ship will be a valid target
-(BOOL)aimedAtShipOfClass:(id)someClass speed:(float)speed tolerence:(float)tolerence distance:(BOOL)disflag{

    rot = fmod(rot,360.0);

	NSArray *a = [[Ship sharedSet] allObjects];

    int i;
    for (i=0;i<[a count];i++){
    
        Ship *sel = [a objectAtIndex: i];
        //allow 20 degree misaim
        
        if (!someClass || [sel isKindOfClass: [someClass class]]){
        
            float distance = sqrt( pow(pos[0]-sel->pos[0],2)+pow(pos[1]-sel->pos[1],2) )-[self radius]-[sel radius];
          
            if ( ((disflag && distance > 150) || !disflag) && distance < 800){
            
               // float shotSpeed = 18.0f;
                //float timeToObject = distance / (shotSpeed + [self speed]);
                
				float timeToTarget;
				NSPoint aim = [self aimForTarget: sel projectileSpeed: speed time:&timeToTarget];
				
				//if (timeToTarget > 20.0) return NO;
				
				if (fabs(angleBetweenVectors([self directionVector], aim)) <= tolerence) {
					return YES;
				}
            
            }
        }

    }
    return NO;

}

//this will tell you if the ship is aimed at any member of a class someClass.
//someclass must be a subclass of game object
-(BOOL)aimedAtAsteroid {

    rot = fmod(rot,360.0);

	NSArray *a = [Asteroid sharedArray];

    int i;
    for (i=0;i<[a count];i++){
    
        Asteroid *sel = [a objectAtIndex: i];
        //allow 20 degree misaim
                
            float distance = sqrt( pow(pos[0]-sel->pos[0],2)+pow(pos[1]-sel->pos[1],2) )-[self radius]-[sel radius];
          
            if (distance < 800){
            
                //float shotSpeed = 18.0f;                
				float timeToTarget;
				NSPoint aim = [self aimForTarget: sel projectileSpeed: 18 time:&timeToTarget];
				
				//if (timeToTarget > 20.0) return NO;
				
				if (fabs(angleBetweenVectors([self directionVector], aim)) <= 10) {
					return YES;
				}
            
            }
    }
    return NO;

}


-(float)shields{
    return shields;
}

//these are constant
-(float)maxShields{
    return 0;
}
-(float)reloadTime{
    return 0;
}
-(unsigned int)healthModules {
    return 0;   
}

+(void)Destroy:(Ship *)sel {
        
    BOOL wasPlayer = NO;
    
    //control is a human
    if (sel->control < 800){
        wasPlayer = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Player Died" object: [NSNumber numberWithInt: [sel netID]]];
    }
    //limit the amount of crystals released (for speed and sanity reasons)
    if (sel->crystals > 15) sel->crystals = 15;
    
    int i,j;
    for (i=0;i<sel->crystals;i++){
        [Crystal SpawnAtX: sel->pos[0]+[Randomness randomFloat: 0 max: 60]-30 y: sel->pos[1]+[Randomness randomFloat: 0 max: 60]-30];
    }
    
    NSArray *keys = [sel powerupsArray];
    for (i = 0;i<[keys count];i++){
        for (j=0;j<[[[sel powerups] objectForKey: [keys objectAtIndex: i] ] intValue];j++){
            [Powerup spawnAtPoint: NSMakePoint(sel->pos[0]+[Randomness randomFloat: 0 max: 60]-30,sel->pos[1]+[Randomness randomFloat: 0 max: 60]-30) type: [keys objectAtIndex: i]];
        }
    }
    for (i=0;i<[sel healthModules];i++){
        [Powerup spawnAtPoint: NSMakePoint(sel->pos[0]+[Randomness randomFloat: 0 max: 60]-30,sel->pos[1]+[Randomness randomFloat: 0 max: 60]-30) type:@"Shield Charge"];
    }
    
    Class selClass = [sel class];
    NSString *objectClass = NSStringFromClass(selClass);
    [sel blowUp];
    [[NSNotificationCenter defaultCenter] removeObserver: sel name: nil object: nil];
    [[Ship sharedSet] removeObject: sel];
    int numberLeft=0;
    //now search to see if he was the last of his kind
	NSArray *a = [[Ship sharedSet] allObjects];
    for (i=0;i<[a count];i++){
        Ship *sel2 = [a objectAtIndex: i];
        if ([sel2 class] == selClass){
            numberLeft++;
        }
    }
    if (numberLeft==0){//if the last one of that type was just destroyed
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"All%@sDestroyed",objectClass] object: nil];
    }

    needsDataResend = YES;
}

-(NSArray *)powerupsArray {
    return [powerupsDictionary allKeys];
}

-(void)setSelectedPowerupIndex:(int)newIndex {
    
    selectedPowerupIndex = newIndex;
    
    if (newIndex < [[self powerupsArray] count]){
        selectedPowerupName = [[self powerupsArray] objectAtIndex: newIndex];
    }
    else {
        selectedPowerupIndex = -1;
    }
    
    //NSLog(@"selecting powerup index %d, name %@", selectedPowerupIndex,selectedPowerupName);
    
}

-(void)useSelectedItem {
    
    if (![selectedPowerupName isEqual:@"none selected"] && useItemTime <= 0){
    
        int ammoLeft = [[powerupsDictionary objectForKey: selectedPowerupName] intValue];
        if (ammoLeft <= 0){
            NSLog(@"ERROR: you shouldn't have been able to fire that");
        }
        else {
            if ([selectedPowerupName isEqual:@"Crystal Magnet"]){
                crystalMagnetOn = -crystalMagnetOn+1;
                if (crystalMagnetOn){
				   if (control != CONTROL_COMPUTER) [self fireSound: activateSound];				
                }
                else {
					if (control != CONTROL_COMPUTER) [self fireSound: deactivateSound];
                }
                return;
            }
			if ([selectedPowerupName isEqual:@"Auto-Zapper"]){
                autoZapperOn = !autoZapperOn;
                if (autoZapperOn){
				   if (control != CONTROL_COMPUTER) [self fireSound: activateSound];				
                }
                else {
					if (control != CONTROL_COMPUTER) [self fireSound: deactivateSound];
                }
                return;
            }

            if ([selectedPowerupName isEqual:@"Shield Restore"] && shields == [self maxShields]){
                return;
            }

            ammoLeft--;
            [powerupsDictionary setObject:[NSNumber numberWithInt:ammoLeft] forKey:selectedPowerupName];
            //NSLog(@"Fire %@!  Ammo left %d",selectedPowerupName, ammoLeft);
            [self doPowerupEffectForType:selectedPowerupName];
            useItemTime = [self useItemTime];
            if (ammoLeft <= 0){
                //NSLog(@"Out of ammo for that powerup");
                [powerupsDictionary removeObjectForKey: selectedPowerupName];
                selectedPowerupName = @"none selected";
                [self setSelectedPowerupIndex: 0];
            }
        }
    }
}

//return value is whether or not it found something to do with the powerup
-(BOOL)doPowerupEffectForType:(NSString *)type {

    if ([type isEqual:@"Mass-Seeker"]){
        [Missile spawnFromObject: self type:NSClassFromString(@"Missile")];
        return TRUE;
    }
    if ([type isEqual:@"Dumb Missile"]){
        [DumbMissile spawnFromObject: self type:NSClassFromString(@"Missile")];
        return TRUE;
    }
    if ([type isEqual:@"Auto-Turret"]){
        [Nuke spawnFromObject: self type:NSClassFromString(@"Missile")];
        return TRUE;
    }
    if ([type isEqual:@"Shield Restore"]){
        
        [activateSound play];
        shields = [self maxShields];
        return TRUE;
    }
    NSLog(@"Warning, couldn't find anything to do for powerup '%@'",type);
    return FALSE;
}

-(int)selectedPowerupIndex {

    if ([selectedPowerupName isEqual:@"none selected"] && [[self powerupsArray] count]){
        [self setSelectedPowerupIndex:0];
    }
    needsDataResend = YES;
    return selectedPowerupIndex;
}

-(void)selectNextPowerup {
    
    if ([self selectedPowerupIndex] < [[self powerupsArray] count]-1){
        [self setSelectedPowerupIndex:[self selectedPowerupIndex]+1];
    }
    else {
        [self setSelectedPowerupIndex: 0];
    }
    needsDataResend = YES;
}

-(void)selectPreviousPowerup {

    if ([self selectedPowerupIndex] > 0){
        [self setSelectedPowerupIndex:[self selectedPowerupIndex]-1];
    }
    else {
        [self setSelectedPowerupIndex: [[self powerupsArray] count]-1];
    }
    needsDataResend = YES;
}

-(id)setControlComputer {
    control = CONTROL_COMPUTER;
    return self;
}

-(id)setControl:(unsigned int)controlID {
 
    control = controlID;
    return self;
    
}

-(id)setControlHuman {

    control = CONTROL_HUMAN;    
    return self;
    
}

-(NSDictionary *)powerups{
    return powerupsDictionary;
}

-(void)turnLeft {

    rotvel=[self turningSpeed];
    needsDataResend = YES;

}

-(void)turnRight {

    rotvel=-[self turningSpeed];
    needsDataResend = YES;

}

-(void)accelerate {

    vel[0] += degreeCosine(rot) * [self acceleration]*FRAME;
    vel[1] += degreeSine(rot) * [self acceleration]*FRAME;
    needsDataResend = YES;

}

-(void)fire {

    if (timeBeforeShoot <= 0 ){
        [self fireSuccess];
    }
    
}

//ships conditions allowed it to fire
-(void)fireSuccess {

    [Shot SpawnFrom: self];
    timeBeforeShoot = [self reloadTime];
    needsDataResend = YES;

}

-(void)make {

    [self retain];

    [self assessDanger];
    [self checkCrystals];
    [self checkPowerupModules];
    [self adjustSpeed];
    timeBeforeShoot -= FRAME;
    [self doLevelWrap];
    [self checkAsteroids];
    [self checkShots];
    useItemTime -= FRAME;
    [self doRedTimeEffect];
    
    [self release];
    
	if (shields < [self maxShields]) {
		shields += FRAME * [self shieldRechargeRate];
		if (shields > [self maxShields]) shields = [self maxShields];
	}
	
    if (crystalMagnetOn){
        [self doCrystalMagnetEffect];
    }
	
	if (autoZapperOn) {
		[self doAutoZap];
	}
    
}

-(float)useItemTime {
	return 60;
}

-(BOOL)crystalMagnetState{
    return crystalMagnetOn;   
}

- (BOOL)autoZapperState {
	return autoZapperOn;
}

-(BOOL)doAutoZap {

	float maxtime = 40;

	if (timeSinceAutoZap > 15.0) {

		
		GameObject *a = [self findNearestShipOfClass:NSClassFromString(@"Pirate")];
		float time;
		NSPoint aim;

		float speed = 10.0;

		if (a != nil) aim = [self aimForTarget:a projectileSpeed:speed time: &time];
		if (a == nil || time > maxtime) a = [self findNearestShipOfClass:NSClassFromString(@"GatherBot")];
		if (a != nil) aim = [self aimForTarget:a projectileSpeed:speed time: &time];
		if (a == nil || time > maxtime) a = [self findNearestAsteroid];
		if (a != nil) aim = [self aimForTarget:a projectileSpeed:speed time: &time];

		if (a != nil && time <= maxtime) {
		
			Shot *newShot = [[Shot alloc] init];
			newShot->pos[0]= pos[0]+aim.x*[self radius];
			newShot->pos[1]= pos[1]+aim.y*[self radius];
			newShot->vel[0]= aim.x*speed + vel[0];
			newShot->vel[1]= aim.y*speed + vel[1];
			newShot->rot = atan2(aim.y, aim.x) * 180.0 / pi;
			newShot->time= maxtime;
			newShot->inertia = 0.5f;
			newShot->creator = self;
			newShot->sprite = glob;
			
			float oldRot = rot; // HACK
			rot = newShot->rot;
			if ([self aimedAtShipOfClass:NSClassFromString(@"Argonaut") speed: speed tolerence: 20 distance: NO ] \
				|| [self aimedAtShipOfClass:NSClassFromString(@"Nuke") speed: speed tolerence: 20 distance: NO ]) {
				[newShot release];
				rot = oldRot;
				return FALSE;
			}
			rot = oldRot;
			
			[self fireSound: shootSound];
			[[Shot sharedSet] addObject: newShot];
			[newShot release];
			timeSinceAutoZap = 0.0;
			return TRUE;
		
		}
	}
	timeSinceAutoZap += FRAME;

	return FALSE;

}

-(void)doCrystalMagnetEffect {
    
    //NSLog(@"do effect damnig!");
    Crystal *sel;
    NSEnumerator *enumerator = [[Crystal sharedSet] objectEnumerator];
    while(sel = [enumerator nextObject])
    {    
        
        float xdif = pos[0]-sel->pos[0];
        float ydif = pos[1]-sel->pos[1];
        float power = 10000.0f/(pow(xdif,2)+pow(ydif,2));        
        float angle = atan2(ydif,xdif);
        sel->vel[0] += power*cos(angle);
        sel->vel[1] += power*sin(angle);
        if (sel->rotvel < 30) sel->rotvel+=power/10.0f; //apply a "torque" to speed rotation of crystals

    }
    
}

-(unsigned int)crystals {
    return crystals;
}

-(void)blowUp {

    //what happens when a ship blows up is left to that ship.
}

-(float)shieldRechargeRate {
	return 0.0;
}

-(void)checkShots {

    int i;
	
	NSArray *a = [[Shot sharedSet] allObjects];
	
    for (i=0;i<[a count];i++){
        
        Shot *sel = [a objectAtIndex: i];
        if ([self collideWithObject: sel] && sel->creator != self){
            shields--;
            [self setRedTime: 5];
            //if (shields <=0) [Ship DestroyAtIndex: myIndex];            
            [[Shot sharedSet] removeObject: sel];
            needsDataResend = YES;

        }
    }      
}

-(NSDictionary *)powerupsDictionary {
    return [NSDictionary dictionaryWithDictionary: powerupsDictionary];
}

-(void)setPowerupsDictionary:(NSDictionary *)_powerupsDictionary {
    
    if (powerupsDictionary) [powerupsDictionary release];
    powerupsDictionary = [_powerupsDictionary retain];
    
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        
        [coder encodeFloat:dest forKey:@"dest"];
        [coder encodeInt:control forKey:@"control"];
        [coder encodeFloat:timeBeforeShoot forKey:@"timeBeforeShoot"];
        [coder encodeFloat:useItemTime forKey:@"useItemTime"];
        [coder encodeBool:crystalMagnetOn forKey:@"crystalMagnetOn"];
        [coder encodeObject:powerupsDictionary forKey:@"powerupsDictionary"];
        [coder encodeFloat:shields forKey:@"shields"];
        [coder encodeInt:crystals forKey:@"crystals"];
        [coder encodeObject:selectedPowerupName forKey:@"selectedPowerupName"];
        [coder encodeFloat:invincableTime forKey:@"invincableTime"];

    } else {
        
        [coder encodeValueOfObjCType:@encode(float) at:&dest];
        [coder encodeValueOfObjCType:@encode(int) at:&control];
        [coder encodeValueOfObjCType:@encode(float) at:&timeBeforeShoot];
        [coder encodeValueOfObjCType:@encode(float) at:&useItemTime];
        [coder encodeValueOfObjCType:@encode(BOOL) at:&crystalMagnetOn];
        [coder encodeObject:powerupsDictionary];
        [coder encodeValueOfObjCType:@encode(float) at:&shields];
        [coder encodeValueOfObjCType:@encode(int) at:&crystals];
        [coder encodeObject:selectedPowerupName];
        [coder encodeValueOfObjCType:@encode(float) at:&invincableTime];
        
    }
    return;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        dest = [coder decodeFloatForKey:@"dest"];
        control = [coder decodeIntForKey:@"control"];
        timeBeforeShoot = [coder decodeIntForKey:@"timeBeforeShoot"];
        useItemTime = [coder decodeFloatForKey:@"useItemTime"];
        crystalMagnetOn = [coder decodeBoolForKey:@"crystalMagnetOn"];
        powerupsDictionary = [coder decodeObjectForKey:@"powerupsDictionary"];
        shields = [coder decodeFloatForKey:@"shields"];
        crystals = [coder decodeIntForKey:@"crystals"];
        selectedPowerupName = [coder decodeObjectForKey:@"selectedPowerupName"];
        invincableTime = [coder decodeFloatForKey:@"invincableTime"];
                    
    } else {
        
        [coder decodeValueOfObjCType:@encode(float) at:&dest];
        [coder decodeValueOfObjCType:@encode(int) at:&control];
        [coder decodeValueOfObjCType:@encode(float) at:&timeBeforeShoot];
        [coder decodeValueOfObjCType:@encode(float) at:&useItemTime];
        [coder decodeValueOfObjCType:@encode(BOOL) at:&crystalMagnetOn];
        powerupsDictionary = [[coder decodeObject] retain];
        [coder decodeValueOfObjCType:@encode(float) at:&shields];
        [coder decodeValueOfObjCType:@encode(int) at:&crystals];
        selectedPowerupName = [[coder decodeObject] retain];
        [coder decodeValueOfObjCType:@encode(float) at:&invincableTime];
        
    }
    return self;
}

@end