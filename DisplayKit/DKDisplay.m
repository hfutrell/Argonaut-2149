//---------------------------------------------------------------------------------------
//  DKDisplay.m
//
//  Author(s):		Brian Christensen <brian@zobs.net>
//  	who is (are) hereby known as "The Author(s)".
//
//  Description:	The display class used to capture and manipulate a chosen 
//			display.
//
//  Copyright © 2001-2002 by Alien Orb Software and The Author(s). All rights reserved.
//
//  Permission to use, copy, modify and distribute this source code and its 
//  documentation is hereby granted, provided that both the copyright notice and this 
//  permission notice appear in all copies of the source code, derivative works or 
//  modified versions, and any portions thereof, and that both notices appear in 
//  supporting documentation. You must include a copy of the original documentation in 
//  every copy of the source code you distribute, and you may not offer or impose any 
//  terms on the source code that alter or restrict this license or the recipients' 
//  rights hereunder. You may deploy the source code, provided that you satisfy all the 
//  conditions herein in each instance.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE 
//  LIABLE FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES RESULTING 
//  FROM ANY DEFECT OR INACCURACY IN THIS SOURCE CODE OR ACCOMPANYING MATERIALS, EVEN 
//  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
//
//  The copyright holders retain all rights, title and interest in and to the original 
//  source code. The copyright holders' development, use, reproduction, modification, 
//  sublicensing and distribution of the original source code will not be subject to 
//  this license.
//---------------------------------------------------------------------------------------

#import "DKDisplay.h"

@interface DKDisplay (PrivateAPI)
- (void)restoreDisplayMode;
+ (void)raiseException:(NSString *)exception functionName:(NSString *)functionName error:(CGDisplayErr)error;
    // needs to be class method so that we can use it from the other class methods
    
//- (void)startAsyncThread;
@end

@implementation DKDisplay

const int kDefaultFadeSeconds = 1.5;
const int kMaxNumDisplays = 50;

NSString * const DKGetActiveDisplayListFailedException = @"DKGetActiveDisplayListFailedException";
NSString * const DKDisplayCaptureFailedException = @"DKDisplayCaptureFailedException";
NSString * const DKCaptureAllDisplaysFailedException = @"DKCaptureAllDisplaysFailedException";
NSString * const DKDisplayReleaseFailedException = @"DKDisplayReleaseFailedException";
NSString * const DKReleaseAllDisplaysFailedException = @"DKReleaseAllDisplaysFailedException";
NSString * const DKSetDisplayTransferFailedException = @"DKSetDisplayTransferFailedException";
NSString * const DKGetDisplayTransferFailedException = @"DKGetDisplayTransferFailedException";
NSString * const DKHideCursorFailedException = @"DKHideCursorFailedException";
NSString * const DKShowCursorFailedException = @"DKShowCursorFailedException";
NSString * const DKMoveCursorToPointFailedException = @"DKMoveCursorToPointFailedException";
NSString * const DKDisplayBestModeForParametersFailedException = @"DKDisplayBestModeForParametersFailedException";
NSString * const DKDisplaySwitchToModeFailedException = @"DKDisplaySwitchToModeFailedException";
NSString * const DKGetDisplayTransferByTableFailedException = @"DKGetDisplayTransferByTableFaileDException";
NSString * const DKSetDisplayTransferByTableFailedException = @"DKSetDisplayTransferByTableFailedException";

NSString * const DKCoreGraphicsErrorNum = @"CoreGraphicsErrorNum";

+ (NSArray *)displays
{
    CGDisplayErr err;
    CGDirectDisplayID activeDisplays[kMaxNumDisplays];
    CGDisplayCount displayCount, i;
    NSMutableArray *displayArray = [[NSMutableArray alloc] init];
    
    err = CGGetActiveDisplayList( kMaxNumDisplays, activeDisplays, &displayCount );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKGetActiveDisplayListFailedException functionName:@"CGGetActiveDisplayList()" error:err];
    
    for (i = 0; i < displayCount; i++)
    {
        DKDisplay *currentDisplay = [[DKDisplay alloc] initWithDisplay:activeDisplays[i]];
        [displayArray addObject:currentDisplay];
    }
    
    return displayArray;
}

static DKDisplay *sharedInstance = nil;

+ (DKDisplay *)mainDisplay
{
    return sharedInstance ? sharedInstance : [[self alloc] initWithMainDisplay];
}

- (id)initWithMainDisplay
{
    if (sharedInstance) {
        [self dealloc];
    } else {
        self = [self initWithDisplay:kCGDirectMainDisplay];
        sharedInstance = self;
    }
    
    return sharedInstance;
}

- (id)initWithDisplay:(CGDirectDisplayID)inDisplayID
{
    self = [super init];
    
    if (self)
    {
        displayID = inDisplayID;
        didCaptureAll = NO;
        oldDisplayMode = nil;
        fadeSeconds = kDefaultFadeSeconds;
        isFaded = NO;
//        threadLock = [NSLock lock];
//        fadeConnection = nil;
//        [self startAsyncThread];
    }
    
    return self;
}

- (void)dealloc
{
    if (CGDisplayIsCaptured( displayID )) {
        if (didCaptureAll)
            [self uncaptureAll];
        else
            [self uncapture];
    }
}

- (void)capture
{
    CGDisplayErr err;
    
    err = CGDisplayCapture( displayID );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKDisplayCaptureFailedException functionName:@"CGDisplayCapture()" error:err];
}

- (BOOL)captureWithWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors
{
    // Save the old mode
    oldDisplayMode = [[self currentMode] retain];
    
    [self capture];
    return [self switchToWidth:width height:height colors:colors];
}

- (void)captureAll
{
    CGDisplayErr err;
    
    err = CGCaptureAllDisplays();
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKCaptureAllDisplaysFailedException functionName:@"CGCaptureAllDisplays()" error:err];
    
    didCaptureAll = YES;
}

- (BOOL)captureAllWithWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors
{
    // Save the old mode
    oldDisplayMode = [[self currentMode] retain];
    
    [self captureAll];
    return [self switchToWidth:width height:height colors:colors];
}

- (BOOL)isCaptured
{
    return CGDisplayIsCaptured( displayID );
}

- (BOOL)didCaptureAll
{
    return didCaptureAll;
}

- (void)uncapture
{
    CGDisplayErr err;
    
    // Switch back to the old mode if necessary
    [self restoreDisplayMode];
    
    err = CGDisplayRelease( displayID );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKDisplayReleaseFailedException functionName:@"CGDisplayRelease()" error:err];
}

- (void)uncaptureAll
{
    CGDisplayErr err;
    
    // Switch back to the old mode if necessary
    [self restoreDisplayMode];
    
    err = CGReleaseAllDisplays();
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKReleaseAllDisplaysFailedException functionName:@"CGReleaseAllDisplays()" error:err];
    
    didCaptureAll = NO;
}

- (DKGammaTable)gamma
{
    CGDisplayErr err;
    DKGammaTable table;
    CGTableCount sampleCount;
    
    err = CGGetDisplayTransferByTable( displayID, 256, table.red, table.green, table.blue, &sampleCount );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKGetDisplayTransferByTableFailedException functionName:@"CGGetDisplayTransferByTable()" error:err];

    return table;
}

- (void)setGamma:(DKGammaTable)table
{
    CGDisplayErr err;

    err = CGSetDisplayTransferByTable( displayID, 256, table.red, table.green, table.blue );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKSetDisplayTransferByTableFailedException functionName:@"CGSetDisplayTransferByTable()" error:err];
}

- (void)fadeToGamma:(DKGammaTable)table
{
    [self fadeToGamma:table inSeconds:fadeSeconds];
}

    // The bulk of this method thanks to previous work done by Ian Ollmann in his
    // excellent RezLib library.
- (void)fadeToGamma:(DKGammaTable)table inSeconds:(float)seconds
{
    NSTimeInterval startTime, endTime;
    double currentTime, fraction;
    int i;
    DKGammaTable currentGamma;
    
    // Calculate end time
    startTime = [NSDate timeIntervalSinceReferenceDate];
    endTime = startTime + seconds;
    
    // Save the old gamma values
    oldGammaTable = [self gamma];
    
    //Loop until we run out of time, resetting the gamma as fast as possible
    for (currentTime = [NSDate timeIntervalSinceReferenceDate]; currentTime < endTime; currentTime = [NSDate timeIntervalSinceReferenceDate])
    {
        //The fraction is the percentage of time that we have spend so far in this loop as a value between 0 and 1.0
        fraction = (currentTime - startTime) / seconds;
        
        //Calculate the new gamma based on the amount of time spent so far
        //(1-fraction)startGamma + fraction * endGamma = startGamma + fraction( endGamma - startGamma)
        for (i = 0; i < 256; i++)
        {
            currentGamma.red[i] = oldGammaTable.red[i] + fraction * (table.red[i] - oldGammaTable.red[i]);
            currentGamma.green[i] = oldGammaTable.green[i] + fraction * (table.green[i] - oldGammaTable.green[i]);
            currentGamma.blue[i] = oldGammaTable.blue[i] + fraction * (table.blue[i] - oldGammaTable.blue[i]);
        }
        
        [self setGamma:currentGamma];
    }
    
    [self setGamma:table];
    isFaded = YES;
}

- (void)fadeToColor:(NSColor *)color
{
    [self fadeToColor:color inSeconds:fadeSeconds];
}

- (void)fadeToColor:(NSColor *)color inSeconds:(float)seconds
{
    DKGammaTable gamma;
    int i;
    float red = [color redComponent];
    float green = [color greenComponent];
    float blue = [color blueComponent];
    
    // Construct a new gamma table
    for (i = 0; i < 256; i++ )
    {
        gamma.red[i] = red;
        gamma.green[i] = green;
        gamma.blue[i] = blue;
    }
    
    [self fadeToGamma:gamma inSeconds:seconds];
}

- (void)fadeIn
{
    [self fadeInInSeconds:fadeSeconds];
}

- (void)fadeInInSeconds:(float)seconds
{
    if (isFaded) {
        [self fadeToGamma:oldGammaTable inSeconds:seconds];
        isFaded = NO;
    }
}

- (BOOL)isFaded
{
    return isFaded;
}

- (float)fadeSeconds
{
    return fadeSeconds;
}

- (void)setFadeSeconds:(float)seconds
{
    fadeSeconds = seconds;
}

- (void)hideCursor
{
    CGDisplayErr err;
    
    err = CGDisplayHideCursor( displayID );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKHideCursorFailedException functionName:@"CGDisplayHideCursor()" error:err];
}

- (void)showCursor
{
    CGDisplayErr err;
    
    err = CGDisplayShowCursor( displayID );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKShowCursorFailedException functionName:@"CGDisplayShowCursor()" error:err];
}

- (void)moveCursorToPoint:(NSPoint)point
{
    CGDisplayErr err;
    CGPoint newPoint;

    // Create the CGPoint
    // Here we convert Cocoa's traditional bottom-left coordinates to CoreGraphics' top-left coordinates
    newPoint.x = point.x;
    newPoint.y = [self frame].size.height - point.y;
    
    err = CGDisplayMoveCursorToPoint( displayID, newPoint );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKMoveCursorToPointFailedException functionName:@"CGDisplayMoveCursorToPoint()" error:err];
}

- (int)shieldingWindowLevel
{
    return CGShieldingWindowLevel();
}

- (NSRect)frame
{
    CGRect bounds = CGDisplayBounds( displayID );

    return NSMakeRect( bounds.origin.x, bounds.origin.y, 
                       bounds.size.width, bounds.size.height );
}

- (CGDirectDisplayID)displayID
{
    return displayID;
}

- (unsigned int)colors
{
    return [(NSString *)[[self currentMode] objectForKey:(NSString *)kCGDisplayBitsPerPixel] intValue];
}

- (NSDictionary *)currentMode
{
    return (NSDictionary *)CGDisplayCurrentMode( displayID );
}

- (NSArray *)availableModes
{
    return (NSArray *)CGDisplayAvailableModes( displayID );
}

- (NSDictionary *)bestModeForWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors gotExactMode:(BOOL *)gotExactMode
{
    NSDictionary *bestDisplayMode;
    boolean_t foundExact;
    
    // Find a matching mode
    bestDisplayMode = (NSDictionary *)CGDisplayBestModeForParameters( displayID, colors, width, height, &foundExact );
    if (bestDisplayMode == nil)
        [DKDisplay raiseException:DKDisplayBestModeForParametersFailedException functionName:@"CGDisplayBestModeForParameters()" error:kCGErrorNoneAvailable];
        
    if (foundExact)
        *gotExactMode = YES;
    else
        *gotExactMode = NO;
    
    return bestDisplayMode;
}

- (BOOL)hasResolutionWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors
{
    NSArray *availableModes = [self availableModes];
    NSEnumerator *enumer = [availableModes objectEnumerator];
    NSDictionary *currentMode;
    BOOL foundRez = NO;
    
    // Iterate through the array of modes
    while (currentMode = [enumer nextObject])
    {
        unsigned int currentWidth = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayWidth] intValue];
        unsigned int currentHeight = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayHeight] intValue];
        unsigned int currentColors = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayBitsPerPixel] intValue];
        
        if ((currentWidth == width) && (currentHeight == height) && (currentColors == colors)) {
            foundRez = YES;
            break;
        }
    }
    
    return foundRez;
}

- (BOOL)switchToWidth:(unsigned int)width height:(unsigned int)height
{
    NSDictionary *currentMode;
    unsigned int colorBits;
    
    // Get the current mode
    currentMode = [self currentMode];
    
    // Retrieve the current display colors
    colorBits = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayBitsPerPixel] intValue];
    
    // And set the display to the requested size
    return [self switchToWidth:width height:height colors:colorBits];
}

- (BOOL)switchToWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors
{
    NSDictionary *newDisplayMode;
    BOOL gotExactMode;
    
    // Find a matching mode
    newDisplayMode = [self bestModeForWidth:width height:height colors:colors gotExactMode:&gotExactMode];
    
    // Switch to the mode
    [self switchToMode:newDisplayMode];
    
    return gotExactMode;
}

- (BOOL)switchToColors:(unsigned int)colors
{
    NSDictionary *currentMode;
    unsigned int width, height;
    
    // Get the current mode
    currentMode = [self currentMode];
    
    // Retrieve the current display width and height
    width = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayWidth] intValue];
    height = [(NSString *)[currentMode objectForKey:(NSString *)kCGDisplayHeight] intValue];
    
    // And set the display to the requested color depth
    return [self switchToWidth:width height:height colors:colors];
}

- (void)switchToMode:(NSDictionary *)mode
{
    CGDisplayErr err;
    
    err = CGDisplaySwitchToMode( displayID, (CFDictionaryRef)mode );
    if (err != kCGErrorSuccess)
        [DKDisplay raiseException:DKDisplaySwitchToModeFailedException functionName:@"CGDisplaySwitchToMode()" error:err];
}

- (void *)baseAddress
{
    return CGDisplayBaseAddress( displayID );
}

@end

@implementation DKDisplay (PrivateAPI)

- (void)restoreDisplayMode
{
    if (oldDisplayMode)
    {
        [self switchToMode:oldDisplayMode];
        
        [oldDisplayMode release];
        oldDisplayMode = nil;
    }
}

+ (void)raiseException:(NSString *)exception functionName:(NSString *)functionName error:(CGDisplayErr)error
{
    NSException *theException;
    NSString *theReason;
    NSDictionary *theUserInfo;
    
    // Construct the info
    theReason = [NSString stringWithFormat:@"%@ returned an error (%u).", functionName, error];
    theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:error], DKCoreGraphicsErrorNum, nil];
    
    // Create and raise the exception
    theException = [NSException exceptionWithName:exception reason:theReason userInfo:theUserInfo];
    [theException raise];
}

@end
