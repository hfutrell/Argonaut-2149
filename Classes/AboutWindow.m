//
//  HighScoreWindow.m
//  Argonaut
//
//  Created by Holmes on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AboutWindow.h"
#import "PreferenceController.h"

#define NUMBER_OF_SCREENS ([[[PreferenceController sharedInstance] prefForKey:@"cheats"] intValue] ? 6 : 4)

@implementation AboutWindow

-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)_bigFont smallFont:(GLFont *)_font buttonSprite:(GLSprite *)_buttonSprite view:(NSView *)_GLView screenNumber:(int)screenNumber {
        
    self = [self initWithFrame: NSMakeRect(0,0,0,0) sprite: windowSprite];
    [self center:NSMakePoint(horizontalResolution,verticalResolution)];
    
    [self setClipToFrame:YES];
    
    font = [_font retain];
    bigFont = [_bigFont retain];
    buttonSprite = [_buttonSprite retain];
    GLView = _GLView;
    
    [self loadTextFileNumber: currentScreenNumber];
    
    currentScreenNumber = screenNumber;

    [self setShouldDisplay: NO];
    
    return self;

}

-(void)dealloc {
    [previousButton release];
	[nextButton release];
    [titleField release];
    [buttonSprite release];
    [font release];
	[bigFont release];
	int i;
	for (i=0; i<30; i++) {
		[contentText[i] release];
	}
	[super dealloc];
}

-(void)setShouldDisplay:(BOOL)state {
    
    [super setShouldDisplay:state];
    if (state){
        [self animateToFrame:NSMakeRect((horizontalResolution-427) / 2.0f,(verticalResolution-(numberOfLines*24+70+80)) / 2.0f,472,numberOfLines*24+70+80) displayContents: NO hideWhenFinished: NO];
    }
    
}

-(void)display {
 
    [super display];
    //[self center:NSMakePoint(horizontalResolution,verticalResolution)];
}

-(void)continuePushed {

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"About Continue Button Pushed" object: self];
    
    [self animateToFrame:NSMakeRect(horizontalResolution/2.0f,verticalResolution/2.0f,0,0) displayContents: NO hideWhenFinished: YES];

}

-(void)next {
    
    currentScreenNumber = (currentScreenNumber == NUMBER_OF_SCREENS) ? 0 : currentScreenNumber+1;
    [self loadTextFileNumber: currentScreenNumber];
    
}

-(void)previous {
    
    currentScreenNumber = (currentScreenNumber == 0) ? NUMBER_OF_SCREENS : currentScreenNumber-1;
    [self loadTextFileNumber: currentScreenNumber];
    
}

-(void)loadTextFileNumber:(int)number {
    
    NSString *path = [ NSString stringWithFormat:@"%@/data/aboutScreens/about%d.txt", [[NSBundle mainBundle] resourcePath], number ];
    if (![[NSFileManager defaultManager] fileExistsAtPath: path]){
        NSLog(@"ERROR, cannot find about file %@!",path);
        return;
    }
    
    [self removeAllChildren];
    
    NSArray *stringsFromFile = [[NSString stringWithContentsOfFile: path] componentsSeparatedByString:@"\n"];
    
    titleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,30,0,0)
                                               font: bigFont
                                             string:@"You should not see this"];
    
    [titleField alignCenter];
    
    [self addChild: titleField];
    
    [titleField setString:[stringsFromFile objectAtIndex: 0]];
    
    numberOfLines=0;
    for (numberOfLines=1;numberOfLines<[stringsFromFile count];numberOfLines++){
        
        GLTextField *newLine = [[GLTextField alloc] initWithFrame:NSMakeRect(0,numberOfLines*24+46,472,20)
                                                             font: font
                                                           string: [stringsFromFile objectAtIndex: numberOfLines] ];                                
        
        [newLine alignCenter];
        [self addChild: newLine];
		[newLine release];
        
    }

    GLPushButton *continueButton = [[GLPushButton alloc] initWithSprite: buttonSprite
                                        rect: NSMakeRect(108,numberOfLines*24+70-16,0,0)
                                        action:@selector(continuePushed)
                                        target:self
                                        view:(NSOpenGLView *)GLView];
    
    GLSprite *leftArrowButton = [[GLSprite alloc] initWithImages:@"data/interface/arrowButtons/left" extension:@".tga" frames:1];
    GLSprite *rightArrowButton = [[GLSprite alloc] initWithImages:@"data/interface/arrowButtons/right" extension:@".tga" frames:1];
    
    previousButton = [[GLPushButton alloc] initWithSprite: leftArrowButton
                            rect: NSMakeRect(32,numberOfLines*24+70,0,0)
                            action:@selector(previous)
                            target:self
                            view:(NSOpenGLView *)GLView];
        
    nextButton = [[GLPushButton alloc] initWithSprite: rightArrowButton
                    rect: NSMakeRect(408,numberOfLines*24+70,0,0)
                    action:@selector(next)
                    target:self
                    view:(NSOpenGLView *)GLView];
       
    [self addChild: previousButton];
    [self addChild: nextButton];
    
    [self animateToFrame:NSMakeRect((horizontalResolution-427) / 2.0f,(verticalResolution-(numberOfLines*24+70+80)) / 2.0f,472,numberOfLines*24+70+80) displayContents: YES hideWhenFinished: NO];
    
        [continueButton setTitleText:@"Close" font:bigFont];
        //[self setFrame:NSMakeRect(0,0,472,numberOfLines*24+70+96)];
        [self addChild: continueButton];
        //[self center:NSMakePoint(horizontalResolution,verticalResolution)];
	
	[continueButton release];
	[leftArrowButton release];
	[rightArrowButton release];
}

@end
