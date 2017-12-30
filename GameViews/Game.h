//
//  Game.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>

#import "FocoaMod.h"

#define NUMBER_OF_MESSAGES_DISPLAYED 3

#define NUMBER_OF_TRACKS 4
#define NONE_PLAYING -17

@class NetSocket,Ship,Model,GLFont,GLButton,GLSprite,GLTexture,GameView,Argonaut,WeaponStore,GLTextField,GLWindow,GLProgressIndicator;
@class HighScoresController,HighScoreWindow,Missile,Level,AboutWindow,GameObject;

@interface Game : NSResponder {
    
    NetSocket *mSocket;
    
    Ship *playerShip;
    
    GLSprite *HUDSprite,*barSprite,*windowSprite,*buttonSprite,*radarSymbol,*sweepGraphic,*lifeGraphic,*listButtonSprite,*smallButtonSprite;
    GLTexture *backgroundTexture,*backgroundTexture2;
    GLFont *smallFont,*bigFont;
    
    float displayedHealth;
    int score;
    int lives;
    int currentLevel;
    int crystals;
    float planetRotation;
    
    float radarRotation;
    
    FocoaStream *music[NUMBER_OF_TRACKS],*whooshSound;
    
    float titleTextTime,titleTextOpacity;
    
    Level *level;
    
    GLTextField *textField,*powerupField;
    
    NSPoint inPoint,outPoint;
    NSPoint radarInPoint,radarOutPoint;
    
    //float camerarot;
    BOOL cameraLocked;
    float camera[2];
    
    GLWindow *HUDWindow,*gameOverWindow,*scoresWindow,*radarWindow,*pauseWindow,*controlsWindow,*saveGameWindow;
    WeaponStore *weaponStoreWindow;
    GLProgressIndicator *healthIndicator;   
    GLTextField *scoreField,*crystalsField,*didQualifyField,*gameOverField,*nameField,*saveTitleField,*saveNameField,*messageField;
    GLTextField *pingField;
            
    float timeTillNextSlide;
    GLTextField *messageDisplayFields[NUMBER_OF_MESSAGES_DISPLAYED];
    
    //music variables
    BOOL fadingDown;
    BOOL musicPlaying;
    float musicVolume;
    int newTrackIndex,playingIndex;
    float nextLevelTime;
    int destFreq;//destination of frequency of music
    int freq;
    
    NSString *saveGameName;
    
    //multiplayer variables
    BOOL isHost;
    BOOL isClient;
    NSString *mNickname;
    unsigned int netID;
    struct timeval lastTime;
    float timeSinceLastPing;
    float timeSinceLastControlSend;
	
	NSNetServiceBrowser *myBrowser;
	NSNetService *serviceBeingResolved;
    
}
-(void)openControls;
-(void)closeControls;
-(void)makeHUD;
+(id)SharedInstance;
-(void)goToMainMenu;
-(void)goToLevel:(int)_levelNumber;
-(void)setTitleText:(NSString *)_text time:(float)_time;
-(void)doTitleText;
-(void)initGameOverWindow;
-(void)showScores;
-(void)drawBackground;

//radar
-(void) doBlipForObject:(GameObject *)sel;
-(void)initPauseWindow;

-(void)handleControls;
//hud window
-(void)zoomHUDWindowOut;
-(void)zoomHUDWindowIn;
-(void)endGame;
-(void)closePauseMenu;
-(void)openPauseMenu;
-(void)drawLives;
-(void)fadeMusic;

-(void)playTrack:(int)newTrackIndex;
-(void)setPowerupField;
-(void)endGame;
-(void)slowMusic;
-(void)endGame;

-(void)initSaveGameWindow;
-(void)openGame:(NSString *)name;
-(void)saveGame;
-(void)attemptSave;
-(void)openSaveWindow;
-(void)closeSaveWindow:(id)sender; 

-(void)respawnPlayer:(NSNumber *)theID;
-(void)startSinglePlayerGame;
-(void)setShip:(Ship *)ship;
@end
