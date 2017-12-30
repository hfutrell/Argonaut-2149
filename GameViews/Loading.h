//
//  Loading.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Aug 10 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <GLSprite.h>
#import <GameView.h>
#import <Model.h>
#import <GLTexture.h>
#import "randomness.h"
#import "GLButton.h"
#import "Frustum.h"
#import "GLFont.h"
#import "Game.h"
#import "GLProgressIndicator.h"

@interface Loading : NSResponder {

    unsigned int itemsLoaded,itemsToLoad,copies;
    id fromView,toView;
    
	BOOL doneLoading;
	
	float totalTime;
	
    GLSprite *backgroundSprite;
    GLProgressIndicator *progressIndicator;
    GLSprite *progressIndicatorSprite,*progressHolder;

}

-(void)transitionBetween:(id)fromView
    to:(id)toView;
-(id)init;
-(void)make;
-(void)setItemsToLoad:(NSNotification *)notification;
-(void)itemLoaded;
-(void)loadingDone;
-(void)dealloc;

@end
