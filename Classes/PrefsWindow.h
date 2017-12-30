//
//  HighScoreWindow.h
//  Argonaut
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLWindow.h>
#import <GLTextField.h>
#import <GLPushButton.h>
#import <GLMatrix.h>
#import <PreferenceController.h>
#import <GameView.h>
#import <GLListButton.h>

@interface PrefsWindow : GLWindow {
    
    GLMatrix *resolutionsMatrix,*playFullScreenMatrix,*bitDepthMatrix, *samplesMatrix;

    GLSprite *windowSprite,*buttonSprite,*listButtonSprite;
    NSView *GLView;
    GLFont *bigFont,*font;

    
    int selectedHorizontal;
    int selectedVertical;
    int selectedColorbits;
    BOOL selectedFullscreen;
	int selectedSamples;
	
    NSMutableArray *shownResolutions;
    GLTextField *changesMadeField;
    
    int leftColY, rightColY, maxCol;
    
    BOOL changesMade;
}
-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)font buttonSprite:(GLSprite *)buttonSprite listButtonSprite:(GLSprite *)listButtonSprite view:(GameView *)GLView;
-(void)applyChanges;
-(void)readPrefs;
-(void)setupResolutionsMatrix;
-(void)setupFullscreenMatrix;
-(void)setupMultiSamplesMatrix;
-(void)checkForChanges;
-(BOOL)isChanged;
-(void)setToMatchPrefs;
-(void)setupBitDepthMatrix;
@end
