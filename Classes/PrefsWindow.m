//
//  HighScoreWindow.m
//  Argonaut
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PrefsWindow.h"

@implementation PrefsWindow

-(id)initWithSprite:(GLSprite *)_windowSprite bigFont:(GLFont *)_bigFont smallFont:(GLFont *)_font buttonSprite:(GLSprite *)_buttonSprite listButtonSprite:(GLSprite *)_listButtonSprite view:(GameView *)_GLView {
    
    
    windowSprite=_windowSprite;
    buttonSprite=_buttonSprite;
    listButtonSprite=_listButtonSprite;
    GLView=_GLView;
    bigFont=_bigFont;
    font=_font;
    
    self = [self initWithFrame: NSMakeRect(0,0,0,0)
                        sprite: windowSprite];
    
    [self setShouldDisplay: NO];
    
       
    GLTextField *titleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236+32,16,0,0)
                                    font: bigFont
                                    string:@"Options"];
    [titleField alignCenter];
    [self addChild: titleField];
    
	// left column
    [self setupResolutionsMatrix];
    // right column
	[self setupBitDepthMatrix];
	[self setupMultiSamplesMatrix];
	[self setupFullscreenMatrix];
	
    //ypos+=32;
    
	maxCol = rightColY > leftColY ? rightColY : leftColY;
	
    GLPushButton *cancelButton = [[GLPushButton alloc] initWithSprite: buttonSprite
                                        rect: NSMakeRect(30,maxCol,0,0)
                                        action:@selector(cancelPushed)
                                        target:self
                                        view:(NSOpenGLView *)GLView];
    
    [cancelButton setTitleText:@"Cancel" font:font];
    [self addChild: cancelButton];
        
    
    GLPushButton *applyButton = [[GLPushButton alloc] initWithSprite: buttonSprite
                                    rect: NSMakeRect(30+128+16,maxCol,0,0)
                                    action:@selector(applyPushed)
                                    target:self
                                    view:(NSOpenGLView *)GLView];
        
    [applyButton setTitleText:@"Apply" font:font];
    [self addChild: applyButton];
            
    
    //[matrix setDeselected:@selector(disable) target: selectButton];
    maxCol+=32;
    
    changesMadeField = [[GLTextField alloc] initWithFrame: NSMakeRect(30,maxCol,0,0)
                            font: font
                            string:@"Relaunch app for changes to take effect"];
    [self addChild: changesMadeField];
    [changesMadeField setShouldDisplay:FALSE];
    [self setToMatchPrefs];
    
    //[self setFrame: NSMakeRect(0,0,472+64,ypos+30)];
    
    [self center:NSMakePoint(horizontalResolution,verticalResolution)];
    
	[titleField release];
	[cancelButton release];
	[applyButton release];
	
    return self;
        
}

-(void)setToMatchPrefs {
 
    [playFullScreenMatrix setSelectedIndex: -[[[PreferenceController sharedInstance] prefForKey:@"fullscreenMode"] intValue]+1];
   
	int colorIndex = ([[[PreferenceController sharedInstance] prefForKey:@"colorBits"] intValue] == 16) ? 0 : 1;
    [bitDepthMatrix setSelectedIndex: colorIndex];
   
	 int actHor =[[[PreferenceController sharedInstance] prefForKey:@"horizontalResolution"] intValue];
    int actVer =[[[PreferenceController sharedInstance] prefForKey:@"verticalResolution"] intValue];
    int i;
	BOOL foundResMatch = NO;
    for (i=0;i<[shownResolutions count];i++){
     
        NSDictionary *mode = [shownResolutions objectAtIndex: i];
        int shownHor = [[mode objectForKey: (NSString *)kCGDisplayWidth] intValue];
        int shownVer = [[mode objectForKey: (NSString *)kCGDisplayHeight] intValue];
        if (shownHor == actHor && shownVer == actVer){
            [resolutionsMatrix setSelectedIndex: i];
            foundResMatch = YES;
        }
        
    }
	if (!foundResMatch) {
		[resolutionsMatrix setSelectedIndex: [shownResolutions count]-1];
	}
	
	int samples = [[[PreferenceController sharedInstance] prefForKey:@"samples"] intValue];
	switch(samples) {
		case 0:
		    [samplesMatrix setSelectedIndex: 0];
			break;
		case 2:
		    [samplesMatrix setSelectedIndex: 1];
			break;
		case 4:
		    [samplesMatrix setSelectedIndex: 2];
			break;
		case 6:
		    [samplesMatrix setSelectedIndex: 3];
			break;
		default:
			NSLog(@"unsupported samples option %d", samples);
		    [samplesMatrix setSelectedIndex: 0];
			break;

	}
}

-(void)setupResolutionsMatrix {
    
    int prevx,prevy;
    unsigned int i;
    leftColY = 65;
    
    GLTextField *displayOptionsField = [[GLTextField alloc] initWithFrame: NSMakeRect(30,leftColY,0,0)
                                                                     font: font
                                                                   string:@"Display Resolution"];
    [self addChild: displayOptionsField];    
    
    leftColY+=16;
    
    resolutionsMatrix = [[GLMatrix alloc] init];
    [self addChild: resolutionsMatrix];
    NSRect matrixRect = NSMakeRect(50,leftColY,0,0);    
    [resolutionsMatrix setFrame: matrixRect];
    [resolutionsMatrix setSelected:@selector(selectResolution) target: self];    
    
    NSRect newButtonRect = NSMakeRect(0,0,0,0);
    NSArray *resolutions = [[PreferenceController sharedInstance] validDisplayModes];
    shownResolutions = [NSMutableArray new];
    
    for (i=0;i<[resolutions count];i++){
        NSDictionary *mode = [resolutions objectAtIndex: i];
        int modeWidth = [[mode objectForKey: (NSString *)kCGDisplayWidth] intValue];
        int modeHeight = [[mode objectForKey: (NSString *)kCGDisplayHeight] intValue];
        if (!(prevx == modeWidth && prevy == modeHeight) && modeWidth >= 800 && modeHeight >= 600){ //if the dimensions aren't repeats and its not a wierd asepct ratio
            [shownResolutions addObject: mode];
        }
        prevx = modeWidth;
        prevy = modeHeight;
    }
    
	int excess = [shownResolutions count] - 12;
	if (excess > 0) [shownResolutions removeObjectsInRange: NSMakeRange(0, excess)];
	
    for (i=0;i<[shownResolutions count];i++){
        
        GLListButton *newButton = [[GLListButton alloc] initWithSprite: listButtonSprite
                                        rect: newButtonRect
                                        action: nil
                                        target:self
                                        view: [GameView SharedInstance]];
        
        
        NSDictionary *mode = [shownResolutions objectAtIndex: i];
        int modeWidth = [[mode objectForKey: (NSString *)kCGDisplayWidth] intValue];
        int modeHeight = [[mode objectForKey: (NSString *)kCGDisplayHeight] intValue];
        NSString *description = [NSString stringWithFormat: @"%4dx%4d", modeWidth, modeHeight];
        [newButton setTitleText: description font: font];
        [resolutionsMatrix addChild: newButton];
        newButtonRect.origin.y+=32;
		[newButton release];

    }
    leftColY += 32*[shownResolutions count]+16;
    
	[displayOptionsField release];
	
}

-(void)setupBitDepthMatrix {
    
	rightColY = 65;
	
    GLTextField *bitDepthField = [[GLTextField alloc] initWithFrame: NSMakeRect(30+256,rightColY,0,0)
                                                                font: font
                                                              string:@"Color Depth"];
    [self addChild: bitDepthField];
    
	rightColY += 16;
	
    bitDepthMatrix = [[GLMatrix alloc] init];
    [bitDepthMatrix setFrame: NSMakeRect(50+256,rightColY,0,0)];
    [bitDepthMatrix setSelected:@selector(selectBitDepth) target: self];    

    [self addChild: bitDepthMatrix];

    
    GLListButton *bit16button = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                              rect: NSMakeRect(0,0,0,0)
                                                            action: nil
                                                            target:self
                                                              view: [GameView SharedInstance]];
    
    GLListButton *bit32button = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                             rect: NSMakeRect(0,32,0,0)
                                                           action: nil
                                                           target:self
                                                             view: [GameView SharedInstance]];
    
	rightColY += 64;
	
    [bit16button setTitleText: @"16 bit" font: font];
    [bit32button setTitleText: @"32 bit" font: font];
    [bitDepthMatrix addChild: bit16button];
    [bitDepthMatrix addChild: bit32button];
	
	rightColY += 16;

	[bitDepthField release];
	[bit16button release];
	[bit32button release];

}


-(void)setupMultiSamplesMatrix {

	GLTextField *samplesField = [[GLTextField alloc] initWithFrame: NSMakeRect(30+256,rightColY,0,0)
                                                                font: font
                                                              string:@"Multi-Sampling"];
    [self addChild: samplesField];
	
	rightColY += 16;
	
    samplesMatrix = [[GLMatrix alloc] init];
	[samplesMatrix setFrame: NSMakeRect(50+256,rightColY,0,0)];
    [samplesMatrix setSelected:@selector(selectSamples) target: self];    

	[self addChild: samplesMatrix];
	
    
    GLListButton *samplesOff = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                              rect: NSMakeRect(0,0,0,0)
                                                            action: nil
                                                            target:self
                                                              view: [GameView SharedInstance]];
	GLListButton *samples2x = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                              rect: NSMakeRect(0,32,0,0)
                                                            action: nil
                                                            target:self
                                                              view: [GameView SharedInstance]];
    GLListButton *samples4x = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                              rect: NSMakeRect(0,64,0,0)
                                                            action: nil
                                                            target:self
                                                              view: [GameView SharedInstance]];

    GLListButton *samples6x = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                             rect: NSMakeRect(0,96,0,0)
                                                           action: nil
                                                           target:self
                                                             view: [GameView SharedInstance]];
    
	rightColY += 128;
	
    [samplesOff setTitleText:	@"Off" font: font];
    [samples2x setTitleText:	@"2x" font: font];
	[samples4x setTitleText:	@"4x" font: font];
	[samples6x setTitleText:	@"6x" font: font];

    [samplesMatrix addChild: samplesOff];
    [samplesMatrix addChild: samples2x];
	[samplesMatrix addChild: samples4x];
    [samplesMatrix addChild: samples6x];

	rightColY += 16;
	
	[samplesOff release];
	[samples2x release];
	[samples4x release];
	[samples6x release];
    
	[samplesField release];

}


-(void)setupFullscreenMatrix {
    	
    GLTextField *playfullscreen = [[GLTextField alloc] initWithFrame: NSMakeRect(30+256,rightColY,0,0)
                                                                font: font
                                                              string:@"Play Fullscreen"];
    [self addChild: playfullscreen];
	
    playFullScreenMatrix = [[GLMatrix alloc] init];
    [self addChild: playFullScreenMatrix];
    NSRect matrixRect = NSMakeRect(50+256,rightColY+16,0,0);    
    [playFullScreenMatrix setFrame: matrixRect];
    [playFullScreenMatrix setSelected:@selector(selectFullscreen) target: self];    
    
    GLListButton *yesButton = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                              rect: NSMakeRect(0,0,0,0)
                                                            action: nil
                                                            target:self
                                                              view: [GameView SharedInstance]];
    
    GLListButton *noButton = [[GLListButton alloc] initWithSprite: listButtonSprite
                                                             rect: NSMakeRect(0,32,0,0)
                                                           action: nil
                                                           target:self
                                                             view: [GameView SharedInstance]];
    
	rightColY += 64;
	
    [yesButton setTitleText: @"Yes" font: font];
    [noButton setTitleText: @"No" font: font];
    [playFullScreenMatrix addChild: yesButton];
    [playFullScreenMatrix addChild: noButton];
    
	rightColY += 16;
	
	[yesButton release];
	[noButton release];
	    
}

-(void)cancelPushed {
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Prefs Cancel Button Pushed" object: self];
    [self animateToFrame:NSMakeRect(horizontalResolution/2.0f,verticalResolution/2.0f,0,0) displayContents: NO hideWhenFinished: YES];
    [self setToMatchPrefs];
}

-(void)selectResolution {
    int selectedIndex  = [resolutionsMatrix selectedIndex];
    NSDictionary *mode = [shownResolutions objectAtIndex: selectedIndex];
    selectedHorizontal = [[mode objectForKey: (NSString *)kCGDisplayWidth] intValue];
    selectedVertical   = [[mode objectForKey: (NSString *)kCGDisplayHeight] intValue];
    [self checkForChanges];
}

-(void)selectFullscreen {
    //yes = 0 and no = 1 on the index so reverse it and add 1 to get the bool value
    int selectedIndex = [playFullScreenMatrix selectedIndex];
    selectedFullscreen = !selectedIndex;
    [self checkForChanges];
}

-(void)selectSamples {
    int selectedIndex = [samplesMatrix selectedIndex];
	switch(selectedIndex) {
		case 0:
			selectedSamples = 0;
			break;
		case 1:
			selectedSamples = 2;
			break;
		case 2:
			selectedSamples = 4;
			break;
		case 3:
			selectedSamples = 6;
			break;
		default:
			NSLog(@"Unrecognized samples index clicked");
	}
    [self checkForChanges];

}

-(void)selectBitDepth {
 
    selectedColorbits = (([bitDepthMatrix selectedIndex] == 0) ? 16 : 32);
    [self checkForChanges];
    
}

-(void)checkForChanges{
 
    changesMade = [self isChanged];
    [changesMadeField setShouldDisplay: changesMade];
    
}

-(BOOL)isChanged {
    
    if (selectedHorizontal != [[[PreferenceController sharedInstance] prefForKey:@"horizontalResolution"] intValue]) return TRUE;
    if (selectedVertical != [[[PreferenceController sharedInstance] prefForKey:@"verticalResolution"] intValue]) return TRUE;
    if (selectedColorbits != [[[PreferenceController sharedInstance] prefForKey:@"colorBits"] intValue]) return TRUE;
    if (selectedFullscreen != [[[PreferenceController sharedInstance] prefForKey:@"fullscreenMode"] intValue]) return TRUE;
	if (selectedSamples != [[[PreferenceController sharedInstance] prefForKey:@"samples"] intValue]) return TRUE; 
    return FALSE;

}

-(void)setShouldDisplay:(BOOL)state{
    if (state){
        [self readPrefs];
        [self animateToFrame:NSMakeRect((horizontalResolution-536) / 2.0f,(verticalResolution-(maxCol+30)) / 2.0f,536,maxCol+30) displayContents: NO hideWhenFinished: NO];
    }
    [super setShouldDisplay: state];
}

-(void)readPrefs {
    //NSLog(@"reading prefs");
}

-(void)applyPushed {

    [self applyChanges];
    [self animateToFrame:NSMakeRect(horizontalResolution/2.0f,verticalResolution/2.0f,0,0) displayContents: NO hideWhenFinished: YES];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Apply Button Pushed" object: self];
    
}

-(void)applyChanges {
    [[PreferenceController sharedInstance] setObject: [NSNumber numberWithInt: selectedHorizontal] forKey:@"horizontalResolution"];
    [[PreferenceController sharedInstance] setObject: [NSNumber numberWithInt: selectedVertical] forKey:@"verticalResolution"];
    [[PreferenceController sharedInstance] setObject: [NSNumber numberWithInt: selectedColorbits] forKey:@"colorBits"];
    [[PreferenceController sharedInstance] setObject: [NSNumber numberWithInt: selectedFullscreen] forKey:@"fullscreenMode"];
	[[PreferenceController sharedInstance] setObject: [NSNumber numberWithInt: selectedSamples] forKey:@"samples"];
    [[PreferenceController sharedInstance] savePrefs];
}

-(void)dealloc {
	[playFullScreenMatrix release];
	[bitDepthMatrix release];
	[samplesMatrix release];
	[changesMadeField release];
	[resolutionsMatrix release];
	[super dealloc];
}

@end
