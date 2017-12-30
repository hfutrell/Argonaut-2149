//
//  HighScoreWindow.m
//  Asterex
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "WeaponStoreWindow.h"

@implementation WeaponStoreWindow

-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)smallFont buttonSprite:(GLSprite *)buttonSprite listButtonSprite:(GLSprite *)listButtonSprite view:(NSView *)GLView {

    self = [self initWithFrame: NSMakeRect(128+32,16,472,536)
        sprite: windowSprite];
        
    [self setShouldDisplay: NO];

    GLTextField *titleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,30,0,0)
        font: bigFont
        string:@"Weapon Store"];
        
    [titleField alignCenter];
        
    GLTextField *subTitleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,50,0,0)
        font: bigFont
        string:@"For All Your Destructive Needs"];
        
    [subTitleField alignCenter];

    [self addChild: [titleField autorelease]];
    [self addChild: [subTitleField autorelease]];
    
    NSRect newButtonRect = NSMakeRect(-4,20,0,0);
    NSRect matrixRect = NSMakeRect(29,50-64,0,0);    
    GLMatrix *weaponsMatrix = [[GLMatrix new] autorelease];
    [self addChild: [weaponsMatrix autorelease]];
    [weaponsMatrix setFrame: matrixRect];
    [weaponsMatrix setSelected:@selector(selectWeapon) target: self];
    [weaponsMatrix setDeselected:@selector(deselect) target: self];
            
    int i;
    for (i=0;i<5;i++){
        
        newButtonRect.origin.y+=32;
        GLListButton *newButton = [[GLListButton alloc] initWithSprite: listButtonSprite
            rect: newButtonRect
            action: nil
            target:self
            view: GLView];
        [newButton setTitleText:  @"Sample Object" font: smallFont];
        [weaponsMatrix addChild:[newButton autorelease]];
              
    }
        
    GLPushButton *continueButton = [[GLPushButton alloc] initWithSprite: buttonSprite
        rect: NSMakeRect(32,15*24+100,0,0)
        action:@selector(continuePushed)
        target:self
        view:GLView];
        
    [continueButton setTitleText:@"Continue" font:bigFont];
    [self addChild: [continueButton autorelease]];
        
    return self;

}

-(void)continuePushed {

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Weapon Store Continue Button Pushed" object: self];

}

@end
