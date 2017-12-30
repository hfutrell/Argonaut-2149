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
#import <PreferenceController.h>

@interface AboutWindow : GLWindow {
    
    int numberOfLines;
    int currentScreenNumber;
    GLButton *previousButton,*nextButton;
    GLTextField *titleField;
    GLSprite *buttonSprite;
    GLFont *font,*bigFont;
    GLTextField *contentText[30];
    NSView *GLView;
    
}
-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)_bigFont smallFont:(GLFont *)_font buttonSprite:(GLSprite *)buttonSprite view:(NSView *)GLView screenNumber:(int)screenNumber;
-(void)loadTextFileNumber:(int)number;
@end
