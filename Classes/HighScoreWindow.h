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
#import <HighScoresController.h>
#import <PreferenceController.h>

@interface HighScoreWindow : GLWindow {

    GLTextField *scoreEntry[15];
    HighScoresController *scoresController;

}
-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)font buttonSprite:(GLSprite *)buttonSprite view:(NSView *)GLView;
-(void)refreshScores;
@end
