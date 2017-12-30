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

/* other portions of this code by The Omni Group */

/* GameController.m */

#import "GameController.h"
#import <unistd.h>
#import <DisplayKit.h>

@interface GameController (InternalMethods)<NSApplicationDelegate>
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
@end

@implementation GameController

- (void) awakeFromNib
{ 
    
    [ NSApp setDelegate: self ];   // We want delegate notifications
    renderTimer = nil;
    
	NSLog(@"Zombies = %s", getenv("NSZombieEnabled") );
		
    [ self setVideoMode: self];
        
    //quit if the video window closes
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector:@selector(bailout)
        name: NSWindowWillCloseNotification object: glWindow];
        
    [Randomness initRNG];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(pauseGame)
            name:@"GameShouldPause" object: nil];
            
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(unPauseGame)
            name:@"GameShouldUnPause" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(showCursor)
            name:@"RequestShowCursor" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(hideCursor)
            name:@"RequestHideCursor" object: nil];
    
    [[NSApplication sharedApplication] setDelegate: self];
    
    //NSString *appFolder = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    //[[NSFileManager defaultManager] changeCurrentDirectoryPath:appFolder];
    //NSLog(@"Default = %@",[[NSFileManager defaultManager] currentDirectoryPath]);
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
 
    //NSLog(@"recieved should terminate");
    [[PreferenceController sharedInstance] savePrefs];
    
    if (isFullScreen){
    
        [theDisplay fadeToBlack];
        [fullScreenWindow orderOut:self];
        [theDisplay uncapture];
        [theDisplay fadeIn];
    
    }
    return  NSTerminateNow;
}

-(void)bailout {

    //NSLog(@"game window closed, quitting...");
    [NSApp terminate : self];

}

- (IBAction)setVideoMode:(id)sender {
    
    //don't quit when the video window closes
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowWillCloseNotification object: glWindow];
    
    //Collect the requested features
    //int modeIndex = [[resolutionPopUp selectedItem] tag];
    //NSDictionary *displayMode = [displayModes objectAtIndex: modeIndex];
    fullscreenWidth = [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"horizontalResolution"] intValue];
    fullscreenHeight = [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"verticalResolution"] intValue];  
    fullscreenColorbits = [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"colorBits"] intValue];
    isFullScreen = [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"fullscreenMode"] intValue];
    
    //NSLog(@"resolution selection %d,%d, colorbits %d, fullscreen %d",fullscreenWidth,fullscreenHeight,fullscreenColorbits,shouldBeFullscreen);
    
    if (isFullScreen){
    
		NSLog(@"Going fullscreen, width = %d, height = %d", fullscreenWidth, fullscreenHeight);
	
        theDisplay = [DKDisplay mainDisplay];
        [theDisplay setFadeSeconds:0.5];
        [theDisplay fadeToBlack];
        [theDisplay captureWithWidth:fullscreenWidth height:fullscreenHeight colors:fullscreenColorbits];
        
        fullScreenWindow = [[FullScreenWindow alloc] initWithContentRect:NSMakeRect(0,[[NSScreen mainScreen] frame].size.height-fullscreenHeight,fullscreenWidth,fullscreenHeight)
                                styleMask:NSBorderlessWindowMask
                                backing:NSBackingStoreBuffered
                                defer:NO];
                
        glView = [ [ GameView alloc ] initWithFrame:[ theDisplay frame ]
                                          colorBits: fullscreenColorbits depthBits: 16];
        
        [fullScreenWindow setContentView: glView];
        [fullScreenWindow makeFirstResponder: glView];
        
        
        [fullScreenWindow setLevel:[theDisplay shieldingWindowLevel]];
        [fullScreenWindow makeKeyAndOrderFront:nil];

        [theDisplay fadeIn];
        
    }
    else {
		
		NSLog(@"Windowed mode, width = %d, height = %d", fullscreenWidth, fullscreenHeight);
		
        [ glWindow makeFirstResponder: self ];				
		NSSize visible = [[NSScreen mainScreen] visibleFrame].size;
				
        NSRect frameRect = [NSWindow frameRectForContentRect:NSMakeRect(0,0,fullscreenWidth,fullscreenHeight) styleMask:[glWindow styleMask]];
      
		if (frameRect.size.width > visible.width) {
			fullscreenWidth -= (frameRect.size.width - visible.width);
			NSLog(@"Window Width too large, resizing to %d", fullscreenWidth);
			[[PreferenceController sharedInstance] setObjectButNeverSave:[NSNumber numberWithInt: fullscreenWidth] forKey:@"horizontalResolution"];
		}
		if (frameRect.size.height > visible.height) {
			fullscreenHeight -= (frameRect.size.height - visible.height);
			NSLog(@"Window Height too large, resizing to %d", fullscreenHeight);
			[[PreferenceController sharedInstance] setObjectButNeverSave:[NSNumber numberWithInt: fullscreenHeight] forKey:@"verticalResolution"];
		}

		frameRect = [NSWindow frameRectForContentRect:NSMakeRect(0,0,fullscreenWidth,fullscreenHeight) styleMask:[glWindow styleMask]];
		  
		[ glWindow setFrame: frameRect display:YES];
        [ glWindow center ];
        glView = [ [ GameView alloc ] initWithFrame:[ glWindow frame ]
            colorBits: fullscreenColorbits depthBits: 16];
        [ glWindow setContentView: glView ];
        [ glWindow makeKeyAndOrderFront:self ];
    
    }
    [self setNextResponder: glView];
    [ self setupRenderTimer ];
}


/*
 * Cleanup
 */
- (void) dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [ glWindow release ];
    [ fullScreenWindow release];
    [ glView release ];
    if( renderTimer != nil && [ renderTimer isValid ] )
        [ renderTimer invalidate ];
		
	[super dealloc];
}

- (void)pauseGame {
    [self showCursor];
    isPaused = YES;
}

- (void)unPauseGame {
    [self hideCursor];
    isPaused = NO;
}

-(void)showCursor{
    if (isFullScreen){
        [theDisplay showCursor];
        [theDisplay showCursor];
        [theDisplay showCursor];
        [theDisplay showCursor];//bug in display code, must be called twice :(
    }
}

-(void)hideCursor {
    if (isFullScreen){
        [theDisplay hideCursor];
    }
}

- (void)updateGLView:(NSTimer *)timer{
                
    float milliseconds;
    struct timeval rightNow;

    gettimeofday( &rightNow, NULL );
    milliseconds = ( rightNow.tv_sec - lastTime.tv_sec ) * 1000.0f;
    milliseconds += ( rightNow.tv_usec - lastTime.tv_usec ) / 1000.0f;
    lastTime = rightNow;

    frameTime = milliseconds / 16.667;
    
    if (frameTime > 0 && frameTime < 100.0 && !isPaused /*&& [[NSApplication sharedApplication] isActive]*/) {
    
        [GameView SetFrameMultiply: frameTime];
        [GameObject SetFrameRate: frameTime];        
    }
    else if (isPaused){
    
        [GameView SetFrameMultiply: 0];
        [GameObject SetFrameRate: 0];    
    
    }
    
    if( glView != nil /*&& [[NSApplication sharedApplication] isActive]*/)  [ glView drawRect:[ glView frame ] ];
     //[glView setNeedsDisplay: YES];
}

- (void) setupRenderTimer {
    
    NSTimeInterval timeInterval = 0.01;

   renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
                        target:self
                        selector:@selector( updateGLView: )
                        userInfo:nil repeats:YES ] retain ];
   [ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
                                  forMode:NSEventTrackingRunLoopMode ];
   [ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
                                  forMode:NSModalPanelRunLoopMode ];
                                  
}

@end
