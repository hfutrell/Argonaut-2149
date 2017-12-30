//
//  Main Menu.m
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
#import <Foundation/NSDebug.h>

static GLfloat  LightDif[] = {1.0f, 1.0f, 1.0f, 1.0f};
static GLfloat  LightPos2[] = { 2.0, 2.0, 1.0, 0.0f };

@implementation Menu

-(id)init {

	
    self = [super init];
    
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"Loading Items" object: [NSNumber numberWithInt: 29]];
    
    smallButtonSprite = [[GLSprite alloc] initWithImages:@"data/interface/smallButton/button" extension:@".tga" frames: 4];
    
    glEnable(GL_CULL_FACE);
           
           
    planetTexture = [GLTexture initWithResource: @"data/textures/planets/forbidden.jpg"];
    
    //the logo is using the GLWindow class for its zooming ability.  This allows the logo to zoom off the screen
    //when the high scores come on.
    logo = [[GLSprite alloc] initWithSingleImage:@"data/sprites/asteroidlogo" extension:@".tga"];
    logoInRect = NSMakeRect(0,-32,0,0);
    logoOutRect = NSMakeRect(-512,-32,0,0);
    logoWindow = [[GLWindow alloc] initWithFrame: logoOutRect sprite: logo];
    [logoWindow zoomToPoint: logoInRect.origin];
    
    //The Quadric used for the planet
    myQuadric= gluNewQuadric();    
    gluQuadricNormals( myQuadric, GL_SMOOTH );// Generate smooth normals
    gluQuadricTexture( myQuadric, GL_TRUE );//textured
        
    //THE ASTEROIDS
    float baseScale = 1.0;
    smallModel  = [[Model alloc] initWithResource:@"data/models/asteroid/low/asteroid1.obj" scale: baseScale * 1.0/3.0];
    mediumModel = [[Model alloc] initWithResource:@"data/models/asteroid/low/asteroid2.obj" scale: baseScale * 2.0/3.0];
    largeModel  = [[Model alloc] initWithResource:@"data/models/asteroid/low/asteroid3.obj" scale: baseScale];
    asteroidTexture  = [GLTexture initWithResource:@"data/models/asteroid/asteroid.jpg"];
    
    smallFont = [[GLFont alloc] initWithResource:@"data/fonts/font.tga" xSpacing: 16 ySpacing: 16];
	bigFont = [[GLFont alloc] initWithResource:@"data/fonts/bigfont.tga" xSpacing: 32 ySpacing: 32];
       
    //THE BUTTONS
    buttonSprite = [[GLSprite alloc] initWithImages:@"data/interface/buttons/button" extension:@".tga" frames: 4];
    GLSprite *listButtonSprite = [[GLSprite alloc] initWithImages:@"data/interface/listbutton/listbutton" extension:@".tga" frames: 3];

    NSRect buttonCoords = NSMakeRect(29,50,0,0);
	newGameButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: buttonCoords
        action:@selector(startGame)
        target:self
        view: [GameView SharedInstance]];
        
    [newGameButton setTitleText:@"New Game" font: bigFont];
        
	buttonCoords.origin.y += 64;
    loadGameButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: buttonCoords
        action:@selector(loadGame)
        target:self
        view: [GameView SharedInstance]];
        
    [loadGameButton setTitleText:@"Load Game" font: bigFont];
    
    buttonCoords.origin.y += 64.0f;
    aboutButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: buttonCoords
        action:@selector(showAboutWindow)
        target:self
        view: [GameView SharedInstance]];
    [aboutButton setTitleText:@"About" font: bigFont];
    
    buttonCoords.origin.y += 64;
    highScoresButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: buttonCoords
        action:@selector(showHighScores)
        target:self
        view: [GameView SharedInstance]];
    [highScoresButton setTitleText:@"Scores" font: bigFont];
	
	//THE WINDOW SPRITE
    windowSprite = [[GLSprite alloc] initWithImages:@"data/interface/windows/window/window" extension:@".tga" frames: 9];
	   
	buttonCoords.origin.y += 64;
    prefsButton = [[GLPushButton alloc] initWithSprite: buttonSprite
                                                 rect: buttonCoords
                                               action:@selector(showPrefs)
                                               target:self
                                                 view: [GameView SharedInstance]];
    [prefsButton setTitleText:@"Options" font: bigFont];
    
    buttonCoords.origin.y += 96;
    quitButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: buttonCoords
        action:@selector(quit)
        target:self
        view: [GameView SharedInstance]];
    [quitButton setTitleText:@"Quit" font: bigFont];
       
    
    //where the current window is
    inPoint = NSMakePoint(horizontalResolution-282,20);
    
    //where the main window zooms to
    outPoint1 = NSMakePoint(horizontalResolution-282,600);
    
    //where the subwindows zoom to / from
    outPoint2 = NSMakePoint(horizontalResolution,20);

    NSRect windowRect = NSMakeRect(inPoint.x,inPoint.y,256,512);
    buttonWindow = [[GLWindow alloc] initWithFrame: windowRect sprite: windowSprite];
	[buttonWindow addChild: newGameButton];
    [buttonWindow addChild: loadGameButton];
    [buttonWindow addChild: aboutButton];
    [buttonWindow addChild: highScoresButton];
    [buttonWindow addChild: prefsButton];
    [buttonWindow addChild: quitButton];

    //[self initSinglePlayerWindow];
    //[self initMultiPlayerWindow];
    
    //the high score window
    highScoreWindow = [[HighScoreWindow alloc] initWithSprite:windowSprite bigFont: bigFont smallFont: smallFont buttonSprite: buttonSprite view:[GameView SharedInstance]];

    //the about window
     aboutWindow = [[AboutWindow alloc] initWithSprite:windowSprite bigFont: bigFont smallFont: smallFont buttonSprite: buttonSprite view:[GameView SharedInstance] screenNumber:0];
     prefsWindow = [[PrefsWindow alloc] initWithSprite:windowSprite bigFont: bigFont smallFont: smallFont buttonSprite: smallButtonSprite listButtonSprite:listButtonSprite view:[GameView SharedInstance]];
    
    //level selection menu
    windowRect.origin = outPoint2;
    levelWindow = [[GLWindow alloc] initWithFrame: windowRect sprite: windowSprite];   
    
    NSRect playCoords = NSMakeRect(29,30+320,0,0);
    selectButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: playCoords
        action:@selector(loadSelectedGame)
        target:self
        view: [GameView SharedInstance]];
    [selectButton setTitleText:@"Select" font: bigFont];
    [selectButton disable];
    
    voteButton = [[GLPushButton alloc] initWithSprite: nil
                    rect: NSMakeRect(0,verticalResolution-16,420,16)
                    action:@selector(vote)
                    target:self
                    view: [GameView SharedInstance]];
    
    [voteButton setTitleText:@"Visit The Argonaut Webpage" font: smallFont];

        
    playCoords.origin.y = 30+384;
    cancelButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: playCoords
        action:@selector(closeLevelWindow)
        target:self
        view: [GameView SharedInstance]];
    [cancelButton setTitleText:@"Cancel" font: bigFont];
    //[cancelButton setKeyEquivalent: 27];
    
    //setup the buttons for all the levels
    NSArray *saveGameArray=[self saveGameArray];
    
    NSRect newButtonRect = NSMakeRect(-4,20,0,0);
    NSRect matrixRect = NSMakeRect(29,50-64,0,0);    
    matrix = [[GLMatrix alloc] init];
    [levelWindow addChild: matrix];
    [matrix setFrame: matrixRect];
    [matrix setSelected:@selector(enable) target: selectButton];
    [matrix setDeselected:@selector(disable) target: selectButton];
    
    unsigned int i;
    for (i=0;i<[saveGameArray count];i++){
    
        newButtonRect.origin.y+=32;
        GLListButton *newButton = [[GLListButton alloc] initWithSprite: listButtonSprite
            rect: newButtonRect
            action: nil
            target:self
            view: [GameView SharedInstance]];
        NSString *titleText = [[self saveGameArray] objectAtIndex: i];
        [newButton setTitleText: titleText font: smallFont];
        [matrix addChild: newButton];
		[newButton release];
    }
    //end setup
         
    GLTextField *chooseField = [[GLTextField alloc] initWithFrame: NSMakeRect(5+16,10,128,0)
        font: smallFont
        string:@"Select a Save Game"];
    //[chooseField alignCenter];
            
    [levelWindow addChild: selectButton];
    [levelWindow addChild: cancelButton];
    [levelWindow addChild: chooseField];

	[chooseField release];


    //end level selection menu
         
    unsigned int j;
    for (i=0;i<MENU_ASTEROIDS;i++){
    
        //remember to dealloc him!
        asteroid[i] = (MenuAsteroid *)malloc(sizeof(MenuAsteroid));
    
        switch( [ Randomness randomInt: 0 max: 9 ] ){
        
            case 0:
                asteroid[i]->model = largeModel;
                break;
            case 1:
            case 2:
            case 3:
                asteroid[i]->model = mediumModel;
                break;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
                asteroid[i]->model = smallModel;
                break;
            default:
                NSLog(@"Error, invalid asteroid selection case");
                break;
                
        }
        float orbit = [Randomness randomFloat: 0 max: 2*pi]; //degree orbit around planet
        asteroid[i]->orbit = (orbit / (2*pi))*360;
        float distanceFromPlanet = [Randomness randomFloat: 11 max: 25];
        asteroid[i]->pos[0] = cos(orbit)*distanceFromPlanet;//distance from planet
        asteroid[i]->pos[1] = sin(orbit)*distanceFromPlanet;
        asteroid[i]->pos[2] = [Randomness randomFloat: 0 max: 2]-1.0;
        
		asteroid[i]->rotamt = [Randomness randomFloat: 0 max: 2*pi]; //the asteroids rotation
		asteroid[i]->rotvel = [Randomness randomFloat: 0 max: 1]; //how fast spinning on that axis

		for (j=0;j<3;j++){
			asteroid[i]->rotaxis[j] = [Randomness randomFloat: 0 max: 1];
		
        }
    }
    
    
    //the sound effects
    whooshSound = [[FocoaMod alloc] initWithResource:@"data/sounds/whoosh.wav" mode: FSOUND_2D];
    menuMusic = [[FocoaStream alloc] initWithResource:@"data/music/title.mp3" mode: FSOUND_LOOP_NORMAL];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Loading Complete" object: self];
          
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(zoomHighScoreWindowOut:) 
        name: @"High Scores Continue Button Pushed" object: nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(aboutWindowOut:) 
        name: @"About Continue Button Pushed" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(prefsWindowOut:) 
        name: @"Prefs Cancel Button Pushed" object: nil];
    
    //when the apply button is pushed from the prefs
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(prefsWindowOut:) 
        name: @"Apply Button Pushed" object: nil];
    
    [menuMusic play];
    
    background = [[GLSprite alloc] initWithSingleImage:@"data/backgrounds/background" extension: @".jpg"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestShowCursor" object: self];
          
    return self;

}


-(void)cancelSinglePlayer {
    
    [buttonWindow zoomToPointAndHide: outPoint2];
    [buttonWindow zoomToPoint: inPoint];
    [whooshSound play];
    
}

-(void)loadGame {
 
    [buttonWindow zoomToPointAndHide: outPoint1];
    [levelWindow zoomToPoint: inPoint];
    [whooshSound play];

}

-(void)showHighScores {
 
    [buttonWindow zoomToPointAndHide: outPoint1];
    [logoWindow zoomToPointAndHide: logoOutRect.origin];
    [highScoreWindow setShouldDisplay: YES];
    [whooshSound play];

}

-(void)showAboutWindow {
 
    [buttonWindow zoomToPointAndHide: outPoint1];
    [logoWindow zoomToPointAndHide: logoOutRect.origin];
    [aboutWindow setShouldDisplay: YES];
    [whooshSound play];

}

-(void)vote {
 
    [[NSWorkspace sharedWorkspace] openURL:[NSURL
            URLWithString:@"http://futrellsoftware.com/argonaut/redirect.html"]];
    
    if ([[[PreferenceController sharedInstance] prefForKey:@"fullscreenMode"] intValue]){
        [NSApp terminate: self];
    }
    
}

-(void)showPrefs {
    
    [buttonWindow zoomToPointAndHide: outPoint1];
    [logoWindow zoomToPointAndHide: logoOutRect.origin];
    [prefsWindow setShouldDisplay: YES];
    [whooshSound play];
    
}

-(void)prefsWindowOut:(NSNotification *)aNotification {
    
    [buttonWindow zoomToPoint: inPoint];
    [logoWindow zoomToPoint: logoInRect.origin];
    [whooshSound play];
    
}

-(void)aboutWindowOut:(NSNotification *)aNotification {

    [buttonWindow zoomToPoint: inPoint];
    [logoWindow zoomToPoint: logoInRect.origin];
    [whooshSound play];
        
}

-(void)zoomHighScoreWindowOut:(NSNotification *)aNotification {

    [buttonWindow zoomToPoint: inPoint];
    [logoWindow zoomToPoint: logoInRect.origin];
    [whooshSound play];
    
}

-(void)closeLevelWindow {

    [matrix deselect];
    [levelWindow zoomToPointAndHide: outPoint2];
    [buttonWindow zoomToPoint: inPoint];
    [whooshSound play];

}

-(void)drawBackground {

    [[GameView SharedInstance] view2D];
                
    [background drawFrameAsBackground: 0];
        
    [[GameView SharedInstance] view3D];
    
    glLoadIdentity();
    
    glLightfv(GL_LIGHT1, GL_POSITION, LightPos2);    
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDif);
    
    planetRotation+=0.03*[GameView frameMultiply];

    glEnable(GL_LIGHTING);

    glLoadIdentity();
    glTranslatef(-5,-3,-20);
    glRotatef(80,1,0,0); //tilt towards camera (something towards 90)
    glRotatef(188,0,1,0); //the axis of the planet (90 = uranus)
    glRotatef(planetRotation,0,0,1);
    [planetTexture bind];
    gluSphere( myQuadric, 6, 50, 50 ); //draw the planet
    
    [asteroidTexture bind];
    frustum.CalculateFrustum();
    int i;
    for (i=0;i<MENU_ASTEROIDS;i++){
        //apply frustum culling to make sure the asteroid is actually in view before drawing
        if (frustum.SphereInFrustum(asteroid[i]->pos[0],asteroid[i]->pos[1],asteroid[i]->pos[2],0.5)) {
    
            glPushMatrix();
            
                glTranslatef(asteroid[i]->pos[0], asteroid[i]->pos[1], asteroid[i]->pos[2]);
                glRotatef(asteroid[i]->rotamt+=asteroid[i]->rotvel * FRAME,asteroid[i]->rotaxis[0],asteroid[i]->rotaxis[1],asteroid[i]->rotaxis[2]);
            
                [asteroid[i]->model draw];
                
                //[self drawBillBoardQuad: 2.0];
                
            glPopMatrix();
        
        }
    }
    
    
    glClear(GL_DEPTH_BUFFER_BIT);
    [[GameView SharedInstance] viewPixel];

}

-(void)dealloc {
    
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	/*GLSprites*/
    [background release];
	[logo release];
	[smallButtonSprite release];
	[buttonSprite release];
    [windowSprite release];
	
	/*GLTextures*/
	[planetTexture release];
	[spaceTexture release];
	[asteroidTexture release];
	
	/*models*/
	[largeModel release];
    [mediumModel release];
	[smallModel release];

	/*fonts*/
	[bigFont release];
	[smallFont release];
	
	/*Buttons*/
	[loadButton release];
	[aboutButton release];
	[quitButton release];
	[playButton release];
	[highScoresButton release];
	[prefsButton release];
	[voteButton release];
	[newGameButton release];
	[loadGameButton release];
	[selectButton release];
	[cancelButton release];
	
	[matrix release];
	
	/*GLWindows*/
	[buttonWindow release];
	[levelWindow release];
	[logoWindow release];
	[aboutWindow release];
	[prefsWindow release];
	[highScoreWindow release];
	
	[whooshSound release];
	[menuMusic stop];
	[menuMusic release];

    int n;
    for (n=0;n<MENU_ASTEROIDS;n++){
        free(asteroid[n]);
    }  
	
    free(myQuadric);
    [super dealloc];
}

/*
-(void)drawBillboardQuad:(float)size {

    GLfloat viewMatrix[16];
    glGetFloatv(GL_MODELVIEW_MATRIX, viewMatrix);
    float right[3] = 	{ viewMatrix[0],viewMatrix[4],viewMatrix[8] };
    float up[3]    = 	{ viewMatrix[1],viewMatrix[5],viewMatrix[9] };
    
    //lets draw our quad
    glBegin(GL_QUADS);
        
        //bottom left corner
        glTexCoord2f(0.0,0.0);
        glVertex3f( (right[0]+up[0]) * -size , (right[1]+up[1]) * -size , (right[2]+up[2]) * -size );
        
        //bottom right corner
        glTexCoord2f(1.0,0.0);
        glVertex3f( (right[0]-up[0]) * size , (right[1]-up[1]) * size , (right[2]-up[2]) * size );
        
        //top right corner
        glTexCoord2f(1.0,1.0);
        glVertex3f( (right[0]+up[0]) * size , (right[1]+up[1]) * size , (right[2]+up[2]) * size );

        //top left corner
        glTexCoord2f(0.0,1.0);
        glVertex3f( (up[0]-right[0]) * size , (up[1]-right[1]) * size , (up[2]-right[2]) * size );
    
    glEnd();
    
} */


-(void)make {
        
    //Draw the background with planet
    
    //NSLog(@"Active? %@", [[NSApplication sharedApplication] isActive] ? @"Yes" : @"No");
    
    NSPoint mouseLoc = [[GameView SharedInstance] currentMousePosition];
        
    [self drawBackground];
        
    glLoadIdentity();
    
    //draw the box that holds the buttons
    
    [buttonWindow display];
    [logoWindow display];
    [levelWindow display];
    [aboutWindow display];
    [prefsWindow display];
    [voteButton display];
    [highScoreWindow display];
                    
    glDisable(GL_DEPTH_TEST);
    
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE);  
    //[lenseFlare drawFrameAsBackground: 0];
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //[smallFont printAtX: 0 y: verticalResolution-20 string: "2003 uDevGame Entry, click here to vote!"];
    
    //draw the mouse
    
    //if ([[GameView SharedInstance] isFullScreen]){
    //    glPushMatrix();
    //        glTranslatef(mouseLoc.x,mouseLoc.y,0.0);
    //        [customMouse draw];
    //    glPopMatrix();
    //}
    
    glEnable(GL_DEPTH_TEST);
    
}

-(void)quit {
    [NSApp terminate: self];
}

-(void)startGame {
    [self retain];
    Game *newGame = [Game alloc];
    [[GameView SharedInstance] transitionBetween: self to: newGame];
	[newGame startSinglePlayerGame];
    [newGame goToLevel: 0];
    [self release];
}

-(void)loadSelectedGame {
    
    [self retain];
    Game *newGame = [Game alloc];
    [[GameView SharedInstance] transitionBetween: self to: newGame];
    
    NSString *fullName = [[[matrix selectedCell] titleText] stringByAppendingString:@".arg"];
	[newGame startSinglePlayerGame];
	[newGame openGame:fullName];
    [self release];
    
}

-(NSArray *)saveGameArray {
        
    NSString *saveFileDirectory = [[NSString stringWithString:@"~/Library/Application Support/Argonaut/"] stringByExpandingTildeInPath];

    NSMutableArray *array = [NSMutableArray new];
    NSString *file;
        
    NSDirectoryEnumerator *enumerator = [ [NSFileManager defaultManager]
        enumeratorAtPath:saveFileDirectory];
    
    while (file = [enumerator nextObject]) {
        if ([[file pathExtension] isEqualToString:@"arg"])
            [array addObject: [file stringByDeletingPathExtension]];
    }
    return array;
    
}

- (void) keyDown:(NSEvent *)theEvent
{
    //NSLog(@"menu got keydown");
}

@end
