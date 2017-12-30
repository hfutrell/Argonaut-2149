/*
 * Original Windows comment:
 * "This Code Was Created By Jeff Molofee 2000
 * Modified by Shawn T. to handle (%3.2f, num) parameters.
 * A HUGE Thanks To Fredric Echols For Cleaning Up
 * And Optimizing The Base Code, Making It More Flexible!
 * If You've Found This Code Useful, Please Let Me Know.
 * Visit My Site At nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */
 
 /*Modified by Holmes Futrell to handle game specific things like
 setting resolution from window*/

/* Lesson13Controller.h */

#import <Cocoa/Cocoa.h>
#import "GameView.h"
#import "GameObject.h"
#import "Randomness.h"
#import "FullScreenWindow.h"
#import "PreferenceController.h"
#import <Carbon/Carbon.h>

@class DKDisplay;

@interface GameController : NSResponder
{
    DKDisplay *theDisplay;
    IBOutlet NSWindow *glWindow;
    GameView *glView;
    
    //IBOutlet NSMatrix *colorDepthMatrix;
    //IBOutlet NSButton *playInWindowCheckBox;
    ///IBOutlet NSPopUpButton *resolutionPopUp;
    //IBOutlet NSWindow *videoWindow;
        
    //Used in dealing with framerates;
    struct timeval lastTime;
    float frameTime;
    NSTimer *renderTimer;
    FullScreenWindow *fullScreenWindow;
    
    //hold the fullscreen resolution selected
    unsigned int fullscreenColorbits;
    unsigned int fullscreenWidth,fullscreenHeight;
    
    //NSDictionary *originalDisplayMode;
    
    BOOL isPaused,isFullScreen;

}

- (void) awakeFromNib;
//- (void) keyDown:(NSEvent *)theEvent;
- (void) dealloc;
- (IBAction)setVideoMode:(id)sender;
- (void)bailout;
//-(void)switchResolution;

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;

-(void)showCursor;
-(void)hideCursor;

@end