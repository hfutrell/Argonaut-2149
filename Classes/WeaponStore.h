//
//  WeaponStore.h
//  Argonaut
//
//  Created by Holmes Futrell on Sat Oct 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLWindow.h>
#import <GLTextField.h>
#import <GLPushButton.h>
#import <GLMatrix.h>
#import <GLListButton.h>
#import <Ship.h>
#import <Powerup.h>
#import <GLSprite.h>
#import "Frustum.h"
#import "Asteroid.h"
#import "Randomness.h"
#import <PreferenceController.h>

#define STORE_ASTEROIDS 9

typedef struct _StoreAsteroid {
    
    Model *model;
    float pos[3];
    float rotaxis[3];
    float rotvel;
	float rot;
    BOOL hasBeenReset;
    
} StoreAsteroid;

@class GameView;

@interface WeaponStore : GLWindow {

    NSMutableArray *weaponsArray;
    GLTextField *titleField,*subTitleField,*descriptionField,*crystalsField,*costField,*nameField,*playerHasField;
    GLMatrix *weaponsMatrix;
    Ship *playerShip;
    GLButton *buyButton,*saveButton;
    float displayrot;
    CFrustum frustum;
    Model *stationModel;
    GLTexture *stationTexture;
    GLTexture *background1,*background2;
    
    StoreAsteroid *asteroid[STORE_ASTEROIDS];
    
    GameView *theView;
    
    float zoom,zoom2,zoom3,zoomtime,stationrot;
    Model *smallModel,*mediumModel,*largeModel;
    
    int powerupDrawID;
    
    float scroll[2];
    
}
-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)font buttonSprite:(GLSprite *)smallButtonSprite listButtonSprite:(GLSprite *)listButtonSprite view:(GameView *)GLView;
-(BOOL)initWeaponsArray;
-(void)removeEndLine:(char *)string;

-(void)deselect;
-(void)openWithShip:(Ship *)playerShip;
-(void)selectWeapon;
-(void)weaponStoreContinuePushed;
-(void)returnToLevel;
-(void)drawBackground;
-(void)initAsteroids;
-(void)resetAsteroid:(int)i;
-(void)disableSave;

@end
