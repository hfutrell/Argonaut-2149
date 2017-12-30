//
//  Loading.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Aug 10 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Loading.h"
#import "PreferenceController.h"
#import "GameObject.h"

@implementation Loading

-(void)transitionBetween:(id)_fromView
    to:(id)_toView {
    
    fromView = _fromView;
    toView = _toView;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestHideCursor" object: self];
    
    [[GameView SharedInstance] setRenderScreen: self];
	
	doneLoading = NO;
	totalTime = 0.0;
    [progressIndicator setFloatValue: 0];
    
    //[[GameView SharedInstance] drawRect: [ [GameView SharedInstance] frame ]];
        
    [toView init];
    
    if (fromView) [fromView release];
    
}

-(id)init {
        
    self = [super init];
        
    backgroundSprite = [[GLSprite alloc] initWithSingleImage:@"data/backgrounds/loading" extension:@".png"];
    [backgroundSprite setCoordMode:@"center"];
	
	progressIndicatorSprite = [[GLSprite alloc] initWithImages:@"data/interface/progressbar/progress" extension:@".tga" frames: 3];
    progressIndicator = [GLProgressIndicator initWithFrame: NSMakeRect((horizontalResolution-200)/2, verticalResolution/2.0f+80,200,0) sprite: progressIndicatorSprite];
    progressHolder = [[GLSprite alloc] initWithSingleImage:@"data/interface/progressbar/progressholder" extension:@".tga"];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(setItemsToLoad:) name:@"Loading Items" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(itemLoaded) name:@"Item Loaded" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(loadingDone) name:@"Loading Complete" object: nil];

    return self;

}


-(void)setItemsToLoad:(NSNotification *)notification {

    itemsToLoad = [[notification object] intValue];//[_itemsToLoad intValue];
    itemsLoaded = 0;
    [progressIndicator setMinValue: 0];
    [progressIndicator setMaxValue: itemsToLoad];//[_itemsToLoad floatValue]];
    [progressIndicator setFloatValue: 0];

}

-(void)itemLoaded {

    itemsLoaded++;
    [progressIndicator incrementBy: 1];
    [[GameView SharedInstance] drawRect: [ [GameView SharedInstance] frame ]];

}

-(void)loadingDone {

    if (itemsLoaded != itemsToLoad){
        NSLog(@"Loaded %d items, I thought I was loading %d", itemsLoaded, itemsToLoad);
    }
	doneLoading = YES;
	
}

-(void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [backgroundSprite release];
    [progressIndicatorSprite release];
    [progressIndicator release];
    [progressHolder release];
    
    [super dealloc];
    
}

-(void)make {

	totalTime += FRAME;
	if (doneLoading && totalTime >= 120) {
		[[GameView SharedInstance] setRenderScreen: toView];
	}

    glDisable(GL_DEPTH_TEST);

    //draw the backing behind the progress bar
    [[GameView SharedInstance] viewPixel];
   
	glPushMatrix();
		glTranslatef(horizontalResolution/2.0f, verticalResolution/2.0f - 60, -20);
		[backgroundSprite draw];
	glPopMatrix();

	glPushMatrix();
        glTranslatef((horizontalResolution-200)/2,verticalResolution/2.0f+78,-20);
        [progressHolder draw];
    glPopMatrix();
    [progressIndicator display];
    glEnable(GL_DEPTH_TEST);
}

@end
