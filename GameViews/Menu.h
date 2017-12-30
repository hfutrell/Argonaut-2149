//
//  Main Menu.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLSprite.h>
#import <GameView.h>
#import <Model.h>
#import <GLTexture.h>
#import "randomness.h"
#import "Frustum.h"
#import "GLFont.h"
#import "Game.h"
#import "GLWindow.h"
#import "Level.h"
#import "FocoaMod.h"

#import "GLPushButton.h"
#import "GLListButton.h"
#import "GLMatrix.h"
#import "HighScoreWindow.h"
#import "AboutWindow.h"
#import "PreferenceController.h"
#import "PrefsWindow.h"

#define MENU_ASTEROIDS 200

typedef struct _MenuAsteroid {

    Model *model;
    float pos[3];
    float rotaxis[3];
    float rotamt;
	float rotvel;
    float orbit;

} MenuAsteroid;

@interface Menu : NSResponder {

    GLSprite *background,*logo,*smallButtonSprite,*buttonSprite,*windowSprite;
    GLTexture *planetTexture,*spaceTexture, *asteroidTexture;
    MenuAsteroid *asteroid[MENU_ASTEROIDS];
    Model *largeModel,*mediumModel,*smallModel;
    GLUquadricObj *myQuadric;
    CFrustum frustum;
    GLFont *bigFont,*smallFont;
    float spaceRotation,planetRotation,theTime;
    GLButton *loadButton,*aboutButton,*quitButton,*playButton,*highScoresButton,*prefsButton,*voteButton,*newGameButton, *loadGameButton;
    GLButton *multiplayerButton,*selectButton,*cancelButton;
    GLMatrix *matrix;
    NSPoint inPoint,outPoint1,outPoint2;
    NSRect logoInRect,logoOutRect;
    GLWindow *buttonWindow,*levelWindow,*logoWindow,*aboutWindow,*prefsWindow;
    FocoaMod *whooshSound;
    FocoaStream *menuMusic;
    HighScoreWindow *highScoreWindow;

}
-(id)init;
-(void)make;
-(void)drawBackground;
-(void)startGame;
-(NSArray *)saveGameArray;
- (void)keyDown:(NSEvent *)theEvent;

@end
