//
//  HighScoreWindow.h
//  Asterex
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLWindow.h>
#import <GLTextField.h>
#import <GLPushButton.h>
#import <GLMatrix.h>
#import <GLListButton.h>

@interface WeaponStoreWindow : GLWindow {

    GLTextField *scoreEntry[15];

}
-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)font buttonSprite:(GLSprite *)buttonSprite view:(NSView *)GLView;

@end
