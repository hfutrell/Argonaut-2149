//
//  HighScoreWindow.m
//  Argonaut
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "HighScoreWindow.h"

@implementation HighScoreWindow

- (void)dealloc {

	int i;
	for (i=0; i<15; i++) {
		[scoreEntry[i] release];
	}
	[super dealloc];

}

-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)font buttonSprite:(GLSprite *)buttonSprite view:(NSView *)GLView {

    self = [self initWithFrame: NSMakeRect(0,0,0,0)
        sprite: windowSprite];
    
    [self center:NSMakePoint(horizontalResolution,verticalResolution)];
    
    scoresController = [HighScoresController sharedInstance];
        
    [self setShouldDisplay: NO];

    GLTextField *titleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,30,0,0)
        font: bigFont
        string:@"High Scores"];
        
    [titleField alignCenter];

    [self addChild: titleField];
    
    NSMutableArray *entries = [scoresController scoreEntry];
        
    int i;
    for (i=0;i<[entries count];i++){
        
        NSDictionary *entry = [entries objectAtIndex: i];
        NSString *name = [entry objectForKey:@"name"];
        int theScore = [[entry objectForKey:@"score"] intValue];
        
        scoreEntry[i] = [[GLTextField alloc] initWithFrame:NSMakeRect(32,i*24+70,800,20)
                                font: font
                                string: [NSString stringWithFormat:@"%2d. %25s %7d", i+1,[name lossyCString],theScore] ];
                                
        [self addChild: scoreEntry[i]];
        
    }
        
    GLPushButton *continueButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: NSMakeRect(32,15*24+100,0,0)
        action:@selector(continuePushed)
        target:self
        view:(NSOpenGLView *)GLView];
        
    [continueButton setTitleText:@"Continue" font:bigFont];
    
    
     //GLPushButton *clearScores = [[GLPushButton alloc] initWithSprite: buttonSprite
     //   rect: NSMakeRect(32+132,15*24+100,0,0)
     //   action:@selector(clearScores)
     //   target:self
     //   view:GLView];
        
    //[clearScores setTitleText:@"Clear Scores" font:font];
    
    //[continueButton setKeyEquivalent: 13];//return key
    [self addChild: continueButton];

    if ([scoresController containsEntryOfName:@"cheater"] || [scoresController containsEntryOfName:@"Cheater"] ){
        NSLog(@"cheats enabled");
        [[PreferenceController sharedInstance] setObject:[NSNumber numberWithInt: YES] forKey:@"cheats"];
        [[PreferenceController sharedInstance] savePrefs];
    }
    
	[titleField release];
	[continueButton release];
	
    return self;

}

-(void)clearScores {
    [scoresController clearHighScores: self];
    [self refreshScores];
}

-(void)continuePushed {

    [self animateToFrame:NSMakeRect(horizontalResolution/2.0f,verticalResolution/2.0f,0,0) displayContents: NO hideWhenFinished: YES];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"High Scores Continue Button Pushed" object: self];    

}

-(void)setShouldDisplay:(BOOL)aState {
    [super setShouldDisplay: aState];
    if (aState){
        [self refreshScores]; //if turning on the window, be sure to update the scores
        [self animateToFrame:NSMakeRect((horizontalResolution-427) / 2.0f,(verticalResolution-536) / 2.0f,472,536) displayContents: NO hideWhenFinished: NO];
    }
}

-(void)refreshScores {

    int i;
    NSMutableArray *entries = [[HighScoresController sharedInstance] scoreEntry];
    for (i=0;i<[entries count];i++){
        NSDictionary *entry = [entries objectAtIndex: i];
        NSString *name = [entry objectForKey:@"name"];
        int theScore = [[entry objectForKey:@"score"] intValue];
        [scoreEntry[i] setString: [NSString stringWithFormat:@"%2d. %25s %7d", i+1,[name cString],theScore] ];
    }
    
}


@end
