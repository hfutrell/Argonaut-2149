//
//  Game.m
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "Menu.h"
#import "DisplayKit.h"
#import "PreferenceController.h"
#import "Ship.h"
#import "Crystal.h"
#import "Asteroid.h"
#import "Particle.h"
#import "Explosion.h"
#import "Shot.h"
#import "Powerup.h"
#import "Model.h"
#import "GatherBot.h"
#import "Pirate.h"
#import "GLFont.h"
#import "GLButton.h"
#import "GLSprite.h"
#import "GLTexture.h"
#import "GameView.h"
#import "Argonaut.h"
#import "WeaponStore.h"
#import <GLTextField.h>
#import <GLWindow.h>
#import <GLProgressIndicator.h>
#import <HighScoresController.h>
#import <HighScoreWindow.h>
#import <Missile.h>
#import <Level.h>
#import <AboutWindow.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

#define cheatsEnabled 0
#define cameraSpeed 20

#define SLIDE_TIME_INTERVAL (3*60)

static GLfloat  LightDif[] = {1.0f, 1.0f, 1.0f, 1.0f};
static GLfloat  LightPos2[] = { 2.0, 0.0, 1.0, 0.0f };
static GLfloat  LightAmb[] = { 0.5,0.5,0.5,1.0};

static Game *sharedInstance;

@interface Game (InternalMethods)

- (void)playerDied:(NSNotification *)aNotification;
- (BOOL)deleteOldestFileAtDirectory:(NSString *)directory;

@end


@implementation Game

+(id)SharedInstance {
    return sharedInstance;
}

-(void)setShip:(Ship *)ship {
    
    playerShip = ship;
    
}

-(id)init{

    timeSinceLastPing = 2;
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"Loading Items" object: [NSNumber numberWithInt: 112]];
    
    buttonSprite = [[GLSprite alloc] initWithImages:@"data/interface/buttons/button" extension:@".tga" frames: 4];
    smallButtonSprite = [[GLSprite alloc] initWithImages:@"data/interface/smallButton/button" extension:@".tga" frames: 4];

    listButtonSprite = [[GLSprite alloc] initWithImages:@"data/interface/listbutton/listbutton" extension:@".tga" frames: 3];
    
    radarSymbol = [[[GLSprite alloc] initWithSingleImage:@"data/hud/burp" extension:@".tga"] setCoordMode:@"center"];
    sweepGraphic = [[[GLSprite alloc] initWithSingleImage:@"data/hud/radartrail" extension:@".tga"] setCoordMode:@"center"];
    lifeGraphic = [[GLSprite alloc] initWithSingleImage:@"data/hud/life" extension:@".tga"];    
    
    lives = 3; //should be 3
    
    music[0] = [[FocoaStream alloc] initWithResource:@"data/music/craterDust.mp3" mode: FSOUND_LOOP_NORMAL];
    music[1] = [[FocoaStream alloc] initWithResource:@"data/music/goldencity.mp3" mode: FSOUND_LOOP_NORMAL];
    music[2] = [[FocoaStream alloc] initWithResource:@"data/music/kissmyasteroid.mp3" mode: FSOUND_LOOP_NORMAL];
    music[3] = [[FocoaStream alloc] initWithResource:@"data/music/killco.mp3" mode: FSOUND_LOOP_NORMAL];

    smallFont = [[GLFont alloc] initWithResource:@"data/fonts/Font.tga" xSpacing: 16 ySpacing: 16];
    bigFont = [[GLFont alloc] initWithResource:@"data/fonts/bigfont.tga" xSpacing: 32 ySpacing: 32];
    
    whooshSound = [[FocoaMod alloc] initWithResource:@"data/sounds/whoosh.wav" mode: FSOUND_2D];
    
    //load the hud
    
    inPoint = NSMakePoint(1,1);
    outPoint = NSMakePoint(1,-80);
    
    radarInPoint = NSMakePoint(1,64+16);
    radarOutPoint = NSMakePoint(-256,64+16);
    
	GLSprite *radarSprite = [[GLSprite alloc] initWithSingleImage:@"data/hud/radar" extension:@".tga"];
	
    radarWindow = [[GLWindow alloc] initWithFrame: NSMakeRect(radarOutPoint.x,radarOutPoint.y,0,0)
        sprite: radarSprite	];
	[radarSprite release];
	
    [radarWindow setZoomSpeed: 0.5];

	GLSprite *progressHolder = [[GLSprite alloc] initWithSingleImage:@"data/interface/progressbar/progressholder" extension:@".tga"];

    HUDWindow = [[GLWindow alloc] initWithFrame: NSMakeRect(1,-50,0,0) \
        sprite: progressHolder];
    
	[progressHolder release];
	
    [HUDWindow setZoomSpeed: 0.5];
    
    GLSprite *healthIndicatorSprite = [[GLSprite alloc] initWithImages:@"data/interface/progressbar/progress" extension:@".tga" frames: 3];
    healthIndicator = [GLProgressIndicator initWithFrame: NSMakeRect(2,2,197,0) sprite: healthIndicatorSprite];
    [healthIndicatorSprite release];
	
    scoreField = [[GLTextField alloc] initWithFrame: NSMakeRect(5,21,200,16) font: smallFont string: nil];
    crystalsField = [[GLTextField alloc] initWithFrame: NSMakeRect(5,37,200,16) font: smallFont string: nil];
    powerupField = [[GLTextField alloc] initWithFrame: NSMakeRect(5,37+16,200,16) font: smallFont string: nil];
    
    timeTillNextSlide = SLIDE_TIME_INTERVAL;
    messageField = [[GLTextField alloc] initWithFrame: NSMakeRect(216,4,200,16) font: smallFont string: nil];
    [messageField setEditable: NO];
    [messageField setMaxLength: 50];
    [messageField setShouldDisplay: NO];
    [messageField setTarget: self selector: @selector(sendMessageWithSender:)];

    pingField = [[GLTextField alloc] initWithFrame: NSMakeRect(4,verticalResolution-20,200,16) font: smallFont string: nil];
    
    int i;
    for (i=0;i<NUMBER_OF_MESSAGES_DISPLAYED;i++){
        messageDisplayFields[i] = [[GLTextField alloc] initWithFrame: NSMakeRect(216,20+(i*16),200,16) font: smallFont string: nil];
        [messageDisplayFields[i] setShouldDisplay: YES];
    }
    
    [HUDWindow addChild: powerupField];
    [HUDWindow addChild: healthIndicator];
    [HUDWindow addChild: scoreField];
    [HUDWindow addChild: crystalsField];
    
    backgroundTexture = [GLTexture initWithResource:@"data/backgrounds/space5.jpg"];
    backgroundTexture2 = [GLTexture initWithResource:@"data/backgrounds/space2.jpg"];
        
    [Ship initAssets];
    //[Fighter initAssets];
    [Argonaut initAssets];
    [Missile initAssets];
    [Crystal InitAssets];
    [Asteroid InitAssets];
    [Explosion InitAssets];
    [Particle InitAssets];
    [Pirate InitAssets];
    [GatherBot InitAssets];
    [Shot InitAssets];
    [Powerup initAssets];
    
    textField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,(verticalResolution/2.0f) - 100,horizontalResolution,0) font: bigFont string: nil];
    [textField alignCenter];
      
    windowSprite = [[GLSprite alloc] initWithImages:@"data/interface/windows/window/window" extension:@".tga" frames: 9];
    
    currentLevel=0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(levelBeaten:) 
        name: @"Level Beaten" object: nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(scored:) 
        name: @"Scored" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(playerDied:) 
        name: @"Player Died" object: nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(zoomHighScoreWindowOut:) 
        name: @"High Scores Continue Button Pushed" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(closeControls) 
        name: @"About Continue Button Pushed" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(attemptSave) 
        name: @"GameShouldSave" object: nil];

    sharedInstance = self;
    
    [self initGameOverWindow];
    [self initSaveGameWindow];
    [self initPauseWindow];
	
    weaponStoreWindow = [[WeaponStore alloc] initWithSprite:windowSprite bigFont:bigFont smallFont:smallFont buttonSprite:smallButtonSprite listButtonSprite: listButtonSprite view:[GameView SharedInstance]];
    scoresWindow = [[HighScoreWindow alloc] initWithSprite: windowSprite bigFont: bigFont smallFont: smallFont buttonSprite: buttonSprite view:[GameView SharedInstance]];
        
    playingIndex = NONE_PLAYING;
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Loading Complete" object: self];
    
    controlsWindow = [[AboutWindow alloc] initWithSprite:windowSprite bigFont: bigFont smallFont: smallFont buttonSprite: buttonSprite view:[GameView SharedInstance] screenNumber:0];

    
    freq = 44100;
    destFreq = 44100;
    
    mNickname = NSFullUserName();
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestHideCursor" object: self];

    [GameObject setGame: self];
    
    [self zoomHUDWindowIn];
    
    cameraLocked = YES;
    
    return self;
}

-(void)startSinglePlayerGame {
    
    netID = 0;
	isHost = YES;
    [self respawnPlayer: [NSNumber numberWithInt: netID]];

}

-(void)playTrack:(int)_newTrackIndex {
    
    newTrackIndex = _newTrackIndex;
    
    if (![music[_newTrackIndex] isPlaying]){
        fadingDown = YES;
        //NSLog(@"Play track %d",newTrackIndex);
    }
}

-(void)fadeMusic {
    fadingDown = YES;
}

-(void)handleMusic {
    
    if (freq < destFreq-300){
        freq += (int)(500*FRAME);
    }
    if (freq > destFreq+300){
        freq -= (int)(500*FRAME);
    }
    if (playingIndex >= 0 && playingIndex < NUMBER_OF_TRACKS){
        if ([music[playingIndex] isPlaying]){
            [music[playingIndex] setFrequency: freq ];   
        }
    }
    
    if (fadingDown){
        musicVolume -= (FRAME*2.0f); //about a 2 second fade
        if (playingIndex >= 0 && playingIndex < NUMBER_OF_TRACKS){
            if ([music[playingIndex] isPlaying]){
                [music[playingIndex] setVolume: musicVolume ];
            }
        }
        if (musicVolume <= 0){
            if (playingIndex >= 0 && playingIndex < NUMBER_OF_TRACKS){
                if ([music[playingIndex] isPlaying]){
                    //NSLog(@"stop old track");
                    [music[playingIndex] stop];
                }
            }
            if (newTrackIndex >= 0 && newTrackIndex < NUMBER_OF_TRACKS){
                //NSLog(@"Play new track");
                [music[newTrackIndex] play];
            }
            playingIndex = newTrackIndex;
            newTrackIndex = NONE_PLAYING;
            musicPlaying = YES;
            musicVolume = 255;
            fadingDown = NO;
        }
    }
}

-(void)zoomHighScoreWindowOut:(NSNotification *)aNotification {

    [self goToMainMenu];

}

-(void)levelBeaten:(Level *)level {

    //NSLog(@"Game detects level beaten");
    nextLevelTime = 200;
    [self fadeMusic];
}

-(void)playerDied:(NSNotification *)aNotification {
    
    unsigned int theID = [[aNotification object] intValue];
        
    if (theID == netID){
        playerShip = nil;
        cameraLocked = NO;
        [self zoomHUDWindowOut];
    }
	    
    [self performSelector:@selector(respawnPlayer:) withObject:[NSNumber numberWithInt:theID] afterDelay: 2];
    
}

-(void)handleControls {
    
    //if ([[NSApplication sharedApplication] isActive] && playerShip){ //only if app is in front!
        
        timeSinceLastControlSend+=FRAME;
        
        KeyMap keys;
        GetKeys( keys );
          
        unsigned char *theKeyMap = (unsigned char *)(&keys);
        if ( IsKeyDown( theKeyMap, MAC_ARROW_RIGHT_KEY ) || IsKeyDown( theKeyMap, MAC_G_KEY )) {
		
                [playerShip turnLeft];
             
        }
        if ( IsKeyDown( theKeyMap, MAC_ARROW_LEFT_KEY ) || IsKeyDown( theKeyMap, MAC_D_KEY )) {

                [playerShip turnRight];


        }
        if ( IsKeyDown( theKeyMap, MAC_ARROW_UP_KEY ) || IsKeyDown( theKeyMap, MAC_R_KEY )) {
            
			
                [playerShip accelerate];

			
        }
        if ( IsKeyDown( theKeyMap, MAC_ARROW_DOWN_KEY ) || IsKeyDown( theKeyMap, MAC_F_KEY )) {
                 [playerShip applyBreaks];

        }
        if ( IsKeyDown( theKeyMap, MAC_SPACE_KEY ) ) {
                [playerShip fire];
        }
                
                  
            
    //}
}


-(void)zoomHUDWindowOut {
    [radarWindow zoomToPointAndHide: radarOutPoint];
    [HUDWindow zoomToPointAndHide: outPoint];
    [whooshSound play];
}

-(void)zoomHUDWindowIn {

    [HUDWindow zoomToPoint: inPoint];
    [radarWindow zoomToPoint: radarInPoint];
    [whooshSound play];

}

-(void)scored:(NSNotification *)notification {

    if (playerShip){
    
        score += [[notification object] intValue];
    
    }
}

-(void)nextLevel {

    currentLevel++;
    if(level)[level release];
    level = [Level levelOfNumber: currentLevel];

}

/* attempts to respawn the player, will do so if the player has any lives left, but goes to game over screen if not */
-(void)respawnPlayer:(NSNumber *)theID {
						
	if (lives > 0 ) {
	
		lives--;
		[[Argonaut spawn] setControl: [theID intValue]];
		playerShip = [Ship shipOfNetID:0];
		[self zoomHUDWindowIn];
		[healthIndicator setMinValue: 0];
		[healthIndicator setMaxValue: [playerShip maxShields]];
		[healthIndicator setFloatValue: [playerShip shields]];        
			
	}
	else {
		[self endGame];
	}
	
}

-(void)endGame {
	
    [self closePauseMenu]; //make sure the pause window isn't open, this looks bad!
    [self slowMusic];
    if (playerShip) { //if the player is actually alive (this happens when the player aborts the game) transfer its control to the computer
        [playerShip setControlComputer];
        playerShip = nil;
        [self zoomHUDWindowOut];
    }
    int scorePlacement = [ [HighScoresController sharedInstance] checkWhereScoreShouldGo: score];
    if (scorePlacement >= 0 ){ //if the score places
        [gameOverWindow setShouldDisplay: TRUE];
    }
    else {
        [self showScores];
    }
}

-(void)slowMusic {
    destFreq = 22000;
}

-(void)doRadar {
        
    if ([radarWindow shouldDisplay]){
    
        unsigned int i;
        
        glLoadIdentity();
        
        NSPoint abpos = [radarWindow absolutePosition];
        
        glTranslatef(abpos.x+64,abpos.y+64,0);
        
        glPushMatrix();
            glRotatef(-(radarRotation -= FRAME*3.0)+180,0,0,1); //rotate the sweep and increment sweep rotation
            [sweepGraphic draw];
        glPopMatrix();
        
        radarRotation = fmod(radarRotation,360.0);
        
        if (playerShip){
            for (i=0; i < [[Asteroid sharedArray] count]; /*[[Asteroid sharedArray] count];*/ i++){
                Asteroid *sel = [[Asteroid sharedArray] objectAtIndex: i];
                [self doBlipForObject: sel];
            }
			NSArray *a = [[Ship sharedSet] allObjects];
            for (i=0; i < [a count]; /*[[Asteroid sharedArray] count];*/ i++){
                Ship *sel = [a objectAtIndex: i];
                [self doBlipForObject: sel];
            }
            Crystal *sel;
            NSEnumerator *enumerator = [[Crystal sharedSet] objectEnumerator];
            while(sel = [enumerator nextObject])
                [self doBlipForObject: sel];
            }
        glColor4f(1.0,1.0,1.0,1.0);
    
    }
}

- (void) doBlipForObject:(GameObject *)sel {


    float cameraRelativePosition[2];
    cameraRelativePosition[0] = sel->pos[0] - [playerShip xPosition];
    cameraRelativePosition[1] = sel->pos[1] - [playerShip yPosition];
    
    cameraRelativePosition[0] /= 2400; //scale down due to size of level
    cameraRelativePosition[1] /= 1800;
    
    cameraRelativePosition[0] *= 128; //scale up for size of radar
    cameraRelativePosition[1] *= 128;

    float relativeDistanceSquared = pow(cameraRelativePosition[0],2)+pow(cameraRelativePosition[1],2);
    float maxDistanceSquared = pow(55,2);
    
    if (relativeDistanceSquared < (maxDistanceSquared-(pow(sel->inertia*2,2)))){
    
        glPushMatrix();
        
            glTranslatef(cameraRelativePosition[0],cameraRelativePosition[1],0);
            glScalef(sel->inertia*0.2,sel->inertia*0.2,sel->inertia*0.2);
            [radarSymbol draw];
    
        glPopMatrix();
    
    }

}

- (void) keyDown:(NSEvent *)theEvent
{ 
    unichar unicodeKey;
        
        unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];

        switch( unicodeKey )
        {
        
        case '[':
        case '{':
        case 'x':
        case 'X':
            if (playerShip) [playerShip selectPreviousPowerup];
            break;
        case ']':
        case '}':
        case 'c':
        case 'C':
            if (playerShip) [playerShip selectNextPowerup];
            break;
        case 'Q':
        case 'q':
            if (cheatsEnabled  && playerShip){
                playerShip->crystals+=5;
            }
            break;

        case 'W':
        case 'w':
            if (cheatsEnabled && ![weaponStoreWindow shouldDisplay] && playerShip){
                [weaponStoreWindow openWithShip: playerShip];
            }
            break;

        case 'E':
        case 'e':
            if (cheatsEnabled){
              //  playerShip->shields = playerShip->maxShields;
               // playerShip->invincableTime = 20000;
            }    
            break;

        case 'z':
        case 'Z':
            if (playerShip) [playerShip useSelectedItem];
            break;
        //case 13: //return key
        //case 't':
        case 27: //the escape key
            [self openPauseMenu];
            break;
        }
}

-(void)goToLevel:(int)_levelNumber {
    currentLevel=_levelNumber;
    [level release];
    level = [Level levelOfNumber: _levelNumber];
    if (!level){ //if there are no more levels to play
        [self endGame];
    }

}

-(void)goToMainMenu {

      [[GameView SharedInstance] transitionBetween: self to: [Menu alloc]];

}

-(void)dealloc {

    [mSocket release];
    
	[healthIndicator release];
    
	/* GLTextFields */
	[textField release];
	[powerupField release];
	[scoreField release];
	[crystalsField release];
	[didQualifyField release];
	[gameOverField release];
	[nameField release];
	[saveTitleField release];
	[saveNameField release];
	[messageField release];
	[pingField release];
	
	int i;
	for (i=0; i<NUMBER_OF_MESSAGES_DISPLAYED; i++) {
		[messageDisplayFields[i] release];
	}
    
	/*GLSprites*/
	[HUDSprite release];
    [barSprite release];
	[windowSprite release];
	[buttonSprite release];
	[radarSymbol release];
    [sweepGraphic release];
	[lifeGraphic release];
	[listButtonSprite release];
	[smallButtonSprite release];

	/*Textures*/
	[backgroundTexture release];
	[backgroundTexture2 release];

	/*Fonts*/
	[bigFont release];
    [smallFont release];

	/*GLWindows*/
	[HUDWindow release];
	[gameOverWindow release];
	[scoresWindow release];
	[radarWindow release];
	[pauseWindow release];
	[controlsWindow release];
	[saveGameWindow release];
	[weaponStoreWindow release];

	[Missile deallocAssets];
    [Ship deallocAssets];
    [Argonaut deallocAssets];
    [Pirate deallocAssets];
    [GatherBot deallocAssets];
    [Powerup deallocAssets];
    [Asteroid deallocAssets];
    [Ship  deallocAssets];
    [Crystal  deallocAssets];
    [Shot  deallocAssets];
    [Explosion deallocAssets];
    [Particle deallocAssets];
    
	[whooshSound stop];
	//[whooshSound release];
	
	for (i=0;i<NUMBER_OF_TRACKS;i++){
		[music[i] stop];
		//[music[i] release];
    }
        
    [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];

    if (level) [level release];
    
    if (saveGameName) [saveGameName release];
    
    sharedInstance = nil;
    [super dealloc];

}

-(void)make {

    
    GameView *view = [GameView SharedInstance];

    glLightfv(GL_LIGHT1, GL_POSITION, LightPos2);    
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDif);
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmb);
    
    //playerShip = [Ship shipOfNetID:netID];
    
    if (playerShip) [playerShip setToListeningPoint];
    
    [self handleMusic];
        
    if (![weaponStoreWindow shouldDisplay]){
    
        [view viewPixel];
        if (playerShip) [self handleControls];    
        [self drawBackground];
        glLoadIdentity();
        if (playerShip){
          
            if (cameraLocked){
                camera[0] = [playerShip xPosition]+[playerShip xVelocity]*10;
                camera[1] = [playerShip yPosition]+[playerShip yVelocity]*10;
            }
            else {
                cameraLocked = YES;
                if (camera[0] < [playerShip xPosition] - (cameraSpeed*FRAME)){
                    camera[0]+=(cameraSpeed*FRAME);
                    cameraLocked = NO;
                }
                else if (camera[0] > [playerShip xPosition] + (cameraSpeed*FRAME)){
                    camera[0]-=(cameraSpeed*FRAME);
                    cameraLocked = NO;
                }
                if (camera[1] < [playerShip yPosition] - (cameraSpeed*FRAME)){
                    camera[1]+=(cameraSpeed*FRAME);
                    cameraLocked = NO;
                }
                else if (camera[1] > [playerShip yPosition] + (cameraSpeed*FRAME)){
                    camera[1]-=(cameraSpeed*FRAME);
                    cameraLocked = NO;
                }
            }
        }
        glTranslatef(-camera[0]+(horizontalResolution / 2.0f),-camera[1]+(verticalResolution / 2.0f),0);
        [GameObject setCameraPosition: camera[0] : camera[1] ];
        
        [Asteroid makeAll];
        glDisable(GL_DEPTH_TEST);
        [Shot makeAll];
        [Particle makeAll];
        [Crystal makeAll];
        [Powerup makeAll];
        [Ship makeAll];
        [Explosion makeAll];  
        glLoadIdentity();
        [view viewPixel];
        [self doTitleText];
        [self makeHUD];
        [scoresWindow display];
        
        int i;
        for (i=0;i<NUMBER_OF_MESSAGES_DISPLAYED;i++){
            if (i==NUMBER_OF_MESSAGES_DISPLAYED-1){
                glColor4f(1.0f,1.0f,1.0f,(timeTillNextSlide / SLIDE_TIME_INTERVAL));
            }
            [messageDisplayFields[i] display];
            glColor4f(1.0f,1.0f,1.0f,1.0f);
        }
        
        [messageField display];
        [pingField display];
        [gameOverWindow display];
        [pauseWindow display];
        [controlsWindow display];
        [radarWindow display];
        [self doRadar];
        if (nextLevelTime > 0){
            nextLevelTime-=FRAME;
            if (nextLevelTime < 0 && playerShip){
                [self nextLevel];
                if (level){//only open weapon store if there IS a net level
                    [self playTrack: 3];
                    [weaponStoreWindow openWithShip:playerShip];
                }
            }
        }
        [level make: FRAME/60.0f];
        glEnable(GL_DEPTH_TEST);
    }
    else {
        [weaponStoreWindow display];
        [saveGameWindow display];
    }

}

-(void)makeHUD {
          
    if (playerShip){ //player is alive
        [self setPowerupField];
        [healthIndicator setFloatValue: [playerShip shields]];
        [scoreField setString: [NSString stringWithFormat:@"Score %d",score]];
        [crystalsField setString: [NSString stringWithFormat:@"Crystals %d",[playerShip crystals]]];
    }
    else { //player is dead
        [healthIndicator setFloatValue: 0];
        [crystalsField setString:@"Crystals 0"];
    }
          
    [HUDWindow display];
    if ([HUDWindow shouldDisplay]) [self drawLives];

}

-(void)setPowerupField {
 
    if ([[playerShip selectedPowerupName] isEqual:@"none selected"]){
        [powerupField setString:@""];
        return;
    }
    if ([[playerShip selectedPowerupName] isEqual:@"Crystal Magnet"]){
        BOOL on = [playerShip crystalMagnetState];
        [powerupField setString:[NSString stringWithFormat:@"Crystal Magnet: %@",on ? @"On" : @"Off"]];
        return;
    }
	if ([[playerShip selectedPowerupName] isEqual:@"Auto-Zapper"]){
        BOOL on = [playerShip autoZapperState];
        [powerupField setString:[NSString stringWithFormat:@"Auto-Zapper: %@",on ? @"On" : @"Off"]];
        return;
    }

    [powerupField setString: [NSString stringWithFormat:@"%@:%d",[playerShip selectedPowerupName], [[[playerShip powerups] objectForKey:[playerShip selectedPowerupName]] intValue]]];
    return;
}

-(void)drawLives {

    NSPoint origin = [HUDWindow absolutePosition];
    glPushMatrix();
        glTranslatef(origin.x+120,origin.y+22,0);
        int i;
        for (i=0;i<lives;i++){
            [lifeGraphic draw];
            glTranslatef(25,0,0);
        }
    glPopMatrix();

}

-(void)drawBackground {

    glPushMatrix();
    
    glColor4f(1,1,1,1);
    //glPushAttrib(GL_LIGHTING);
    glDisable(GL_LIGHTING);
    glTranslatef(0,0,-900);
    
	float xSize = [backgroundTexture imageWidth];
	float ySize = [backgroundTexture imageHeight];
	float horsOnScreen = horizontalResolution / xSize;
	float vertsOnScreen = verticalResolution / ySize;
	
    [backgroundTexture bind];
    
    glBegin(GL_QUADS);
    
        //top left
        glTexCoord2f(camera[0]/(800*2.0f),camera[1]/(600 *2.0f));
        glVertex2d(0,0);
        glTexCoord2f((camera[0]/(800*2.0f))+horsOnScreen,camera[1]/(600 *2.0f));
        glVertex2d(horizontalResolution,0);
        glTexCoord2f((camera[0]/(800*2.0f))+horsOnScreen,(camera[1]/(600 *2.0f))+vertsOnScreen);
        glVertex2d(horizontalResolution,verticalResolution);
        glTexCoord2f((camera[0]/(800*2.0f)),(camera[1]/(600 *2.0f))+vertsOnScreen);
        glVertex2d(0,verticalResolution);

    
    glEnd();
    
    [backgroundTexture2 bind];
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);  
    
    glBegin(GL_QUADS);
    
        //top left
        glTexCoord2f(camera[0]/(800*(2.0f/2.0f)),camera[1]/(600*(2.0f/2.0f)));
        glVertex2d(0,0);
        glTexCoord2f((camera[0]/(800*(2.0f/2.0f)))+horsOnScreen,camera[1]/(600*(2.0f/2.0f)));
        glVertex2d(horizontalResolution,0);
        glTexCoord2f((camera[0]/(800*(2.0f/2.0f)))+horsOnScreen,(camera[1]/(600*(2.0f/2.0f)))+vertsOnScreen);
        glVertex2d(horizontalResolution,verticalResolution);
        glTexCoord2f((camera[0]/(800*(2.0f/2.0f))),(camera[1]/(600*(2.0f/2.0f)))+vertsOnScreen);
        glVertex2d(0,verticalResolution);
    
    glEnd();

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glPopMatrix();
    
    //glPopAttrib();
    glEnable(GL_LIGHTING);

}

-(void)setTitleText:(NSString *)_text time:(float)_time {

    [textField setString: _text];
    titleTextTime = _time;
    [textField setShouldDisplay: YES];
    titleTextOpacity=0;

}

-(void)doTitleText {

    //fade up
    if (titleTextOpacity < 1.0 && titleTextTime > 0){
        titleTextOpacity += 0.05 * FRAME;
    }
    else if (titleTextTime <= 0){
        titleTextOpacity -= 0.05 * FRAME;
    }
    
    titleTextTime -= FRAME;
    
    glColor4f(1.0f,1.0f,1.0f,titleTextOpacity);
    [textField display];
    glColor4d(1,1,1,1);
    
    if (titleTextOpacity <= 0 ){
        [textField setShouldDisplay: NO];
    }

}

-(void)initPauseWindow {

    pauseWindow = [[GLWindow alloc] initWithFrame: NSMakeRect(262,120,288,244)
        sprite: windowSprite];
    [pauseWindow center:NSMakePoint(horizontalResolution,verticalResolution)];
        
    [pauseWindow setShouldDisplay :NO];
       
    GLPushButton *abortButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: NSMakeRect(16,32,0,0)
        action:@selector(abort)
        target:self
        view:[GameView SharedInstance]];
    
    [abortButton setTitleText:@"End Game" font: bigFont];
    
    GLPushButton *controlsButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: NSMakeRect(16,32+64,0,0)
        action:@selector(openControls)
        target:self
        view:[GameView SharedInstance]];
    
    [controlsButton setTitleText:@"Controls" font: bigFont];
    
    
     GLPushButton *cancelButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: NSMakeRect(16,32+128,0,0)
        action:@selector(cancelAbort)
        target:self
        view:[GameView SharedInstance]];
     [cancelButton setTitleText:@"Cancel" font: bigFont];
                
    [pauseWindow addChild: controlsButton];
    [pauseWindow addChild: cancelButton];
    [pauseWindow addChild: abortButton];
	
	[cancelButton release];
	[controlsButton release];
	[abortButton release];

}

-(void)openControls {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestShowCursor" object: self];
    [controlsWindow setShouldDisplay:YES];
    [self closePauseMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GameShouldPause" object: nil];;

}

-(void)closeControls {
    
    //[controlsWindow setShouldDisplay:NO];
    [pauseWindow setShouldDisplay: YES];

    
}

-(void)openPauseMenu {
    
    if (![controlsWindow shouldDisplay]){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestShowCursor" object: self];
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"GameShouldPause" object: nil];
    [pauseWindow setShouldDisplay: YES];
    
    }
}

-(void)closePauseMenu {
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"GameShouldUnPause" object: nil];
    [pauseWindow setShouldDisplay: NO];
}

-(void)cancelAbort {
    [self closePauseMenu];
}
-(void)abort {
    [self closePauseMenu];
    [self endGame];
}

-(void)initGameOverWindow {

    gameOverWindow = [[GLWindow alloc] initWithFrame: NSMakeRect(200,200,400,130)
        sprite: windowSprite];
    
    gameOverField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,10,400,0)
                                    font: bigFont
                                    string:@"Game Over"];
                                    
    [gameOverField alignCenter];
                                    
    didQualifyField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,42,400,0)
                            font: smallFont
                            string:@"You got a high score!  Enter your name:"];
                        
    [didQualifyField alignCenter];
                        
    nameField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,74,400,0)
                                    font: bigFont
                                    string: @""];
                                    
    [nameField alignCenter];
    [nameField setEditable: YES];
    [nameField setMaxLength: 18];
    [nameField setTarget: self selector: @selector(addEntryWithSender:)];
    
    [gameOverWindow addChild: gameOverField];
    [gameOverWindow addChild: didQualifyField];
    [gameOverWindow addChild: nameField];
    [gameOverWindow center:NSMakePoint(horizontalResolution,verticalResolution)];
    [gameOverWindow setShouldDisplay: FALSE];
        
}

-(void)initSaveGameWindow {
    
    saveGameWindow = [[GLWindow alloc] initWithFrame: NSMakeRect(200,200,400,100)
                        sprite: windowSprite];
    
        
    saveTitleField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,16,400,0)
                    font: smallFont
                    string:@"Enter a name for your save game:"];
    
    [saveTitleField alignCenter];
    
    saveNameField = [[GLTextField alloc] initWithFrame: NSMakeRect(0,42,400,0)
                                              font: bigFont
                                            string: @""];
    
    [saveNameField alignCenter];
    [saveNameField setEditable: YES];
    [saveNameField setMaxLength: 18];
    [saveNameField setTarget: self selector: @selector(closeSaveWindow:)];
    
    [saveGameWindow addChild: saveTitleField];
    [saveGameWindow addChild: saveNameField];
    [saveGameWindow center:NSMakePoint(horizontalResolution,verticalResolution)];
    [saveGameWindow setShouldDisplay: FALSE];
    
}

-(void)addEntryWithSender:(id)sender {
    int scorePlacement = [ [HighScoresController sharedInstance] checkWhereScoreShouldGo: score];
    NSString *name = [sender stringValue];
    if ([name isEqual:@""]){//name is anonymous if user didn't enter one
        name = @"Anonymous";
    }
    [[HighScoresController sharedInstance] addEntryWithName: name score: score index: scorePlacement];    
    [gameOverWindow setShouldDisplay: NO];
    [self showScores];
}

-(void)showScores {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestShowCursor" object: self];
    [scoresWindow setShouldDisplay: YES];
}


-(void)attemptSave {
 
    if (!saveGameName){ //if the game doesn't know where to save the game, open a dialogue to name it
        //NSLog(@"opening save window");
        [self openSaveWindow];
    }
    else {
        //NSLog(@"save game");
        [self saveGame];
    }
    
}

-(void)openSaveWindow {
    
    [saveGameWindow setShouldDisplay: YES];
    [weaponStoreWindow disable];
    
}

-(void)closeSaveWindow:(id)sender {
    
    [saveGameWindow setShouldDisplay: NO];
    saveGameName = [[NSString stringWithFormat:@"%@%@",[sender stringValue],@".arg"] retain];
    [self attemptSave];
    [weaponStoreWindow enable];
    [weaponStoreWindow disableSave];
    [weaponStoreWindow selectWeapon];
    
}

-(BOOL)deleteOldestFileAtDirectory:(NSString *)directory {
    
    NSDate *oldestDate = [NSDate date];
    NSString *file;
    NSString *oldestFile = nil;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath: directory];
    
    while (file = [enumerator nextObject]) {
        if ([[file pathExtension] isEqualToString:@"arg"]){
            NSString *path = [NSString stringWithFormat:@"%@/%@",directory,file];
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath: path traverseLink:YES];                                
            NSDate *modificationDate = [fileAttributes objectForKey:NSFileModificationDate];
            if ([modificationDate compare: oldestDate] == NSOrderedAscending){
                oldestDate = modificationDate;
                oldestFile = path;
            } 
        }
    }
    //NSLog(@"deleting oldest file %@",oldestFile);
    return [[NSFileManager defaultManager] removeFileAtPath: oldestFile handler: nil];
    
}

-(void)saveGame {
 
    NSString *saveDirectory = [[NSString stringWithString:@"~/Library/Application Support/Argonaut/"] stringByExpandingTildeInPath];
        
    NSArray *directoryContents = [[NSFileManager defaultManager] directoryContentsAtPath: saveDirectory];
    
    if ([directoryContents count] > 9){/*there are too many files in directory*/

        [self deleteOldestFileAtDirectory: saveDirectory];
        
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: saveDirectory]){
        if (![[NSFileManager defaultManager] createDirectoryAtPath: saveDirectory attributes: nil]){
            NSLog(@"Could not create support folder :(");
        }
    }
    
    NSString *saveFilePath = [NSString stringWithFormat:@"%@/%@",saveDirectory,saveGameName];
            
    //needs the following
    NSMutableDictionary *saveDictionary = [NSMutableDictionary new];
    [saveDictionary setObject: [playerShip powerupsDictionary] forKey:@"powerupsDictionary"];
    [saveDictionary setObject: [NSNumber numberWithFloat:[playerShip maxShields]] forKey: @"maxShields"];
    [saveDictionary setObject: [NSNumber numberWithFloat:[playerShip shields]] forKey:@"shields"];
    [saveDictionary setObject: [NSNumber numberWithInt:[playerShip crystals]] forKey:@"crystals"];   
    [saveDictionary setObject: [NSNumber numberWithInt:lives] forKey:@"lives"];    
    [saveDictionary setObject: [NSNumber numberWithInt:currentLevel] forKey:@"currentLevel"];  
    [saveDictionary setObject: [NSNumber numberWithInt:[playerShip selectedPowerupIndex]] forKey:@"selectedPowerupIndex"];  
    [saveDictionary writeToFile: saveFilePath atomically:YES];
    [saveDictionary release];
    
}

-(void)openGame:(NSString *)name {
 
    NSString *saveFilePath = [[NSString stringWithFormat:@"%@%@",@"~/Library/Application Support/Argonaut/",name] stringByExpandingTildeInPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: saveFilePath]){
        NSLog(@"ERROR, cannot find about file %@!",saveFilePath);
        return;
    }
    
    NSMutableDictionary *openedGame = [[NSMutableDictionary alloc] initWithContentsOfFile: saveFilePath];
    
    [playerShip setPowerupsDictionary: [openedGame objectForKey:@"powerupsDictionary"]];
    //[playerShip setMaxShields: [[openedGame objectForKey:@"maxShields"] floatValue]];
    [playerShip setShields: [[openedGame objectForKey:@"shields"] floatValue]];
    [playerShip setCrystals: [[openedGame objectForKey:@"crystals"] intValue]];
    lives = [[openedGame objectForKey:@"lives"] intValue];
    currentLevel = [[openedGame objectForKey:@"currentLevel"] intValue];
    [playerShip setSelectedPowerupIndex: [[openedGame objectForKey:@"selectedPowerupIndex"] intValue]];
    saveGameName = [[saveFilePath lastPathComponent] retain];
    
    if(level)[level release];
    level = [Level levelOfNumber: currentLevel];
    [self playTrack: 3];
    [weaponStoreWindow openWithShip:playerShip];
    [weaponStoreWindow disableSave];

    
    [openedGame release];
}

@end
