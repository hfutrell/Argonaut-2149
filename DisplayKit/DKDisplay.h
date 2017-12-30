//---------------------------------------------------------------------------------------
//  DKDisplay.h
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

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

typedef struct _DKGammaTable
{
    float red[256];
    float green[256];
    float blue[256];
} DKGammaTable;

@interface DKDisplay : NSObject 
{
    @private /* all instance variables are private */
    CGDirectDisplayID displayID;
    BOOL didCaptureAll;
    NSDictionary *oldDisplayMode;
    float fadeSeconds;
    DKGammaTable oldGammaTable;
    BOOL isFaded;
}

+ (NSArray *)displays;
+ (DKDisplay *)mainDisplay;

- (id)initWithMainDisplay;
- (id)initWithDisplay:(CGDirectDisplayID)inDisplayID;

- (void)capture;
- (BOOL)captureWithWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors;
- (void)captureAll;
- (BOOL)captureAllWithWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors;
- (BOOL)isCaptured;
- (BOOL)didCaptureAll;

- (void)uncapture;
- (void)uncaptureAll;

- (DKGammaTable)gamma;
- (void)setGamma:(DKGammaTable)table;

- (void)fadeToGamma:(DKGammaTable)table;
- (void)fadeToGamma:(DKGammaTable)table inSeconds:(float)seconds;
- (void)fadeToColor:(NSColor *)color;
- (void)fadeToColor:(NSColor *)color inSeconds:(float)seconds;

- (void)fadeIn;
- (void)fadeInInSeconds:(float)seconds;

- (BOOL)isFaded;

- (float)fadeSeconds;
- (void)setFadeSeconds:(float)seconds;

- (void)hideCursor;
- (void)showCursor;
- (void)moveCursorToPoint:(NSPoint)point;

- (int)shieldingWindowLevel;

- (NSRect)frame;
- (CGDirectDisplayID)displayID;
- (unsigned int)colors;

- (NSDictionary *)currentMode;
- (NSArray *)availableModes;
- (NSDictionary *)bestModeForWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors gotExactMode:(BOOL *)gotExactMode;

- (BOOL)hasResolutionWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors;

- (BOOL)switchToWidth:(unsigned int)width height:(unsigned int)height;
- (BOOL)switchToWidth:(unsigned int)width height:(unsigned int)height colors:(unsigned int)colors;
- (BOOL)switchToColors:(unsigned int)colors;
- (void)switchToMode:(NSDictionary *)mode;

- (void *)baseAddress;

@end

@interface DKDisplay (DKGammaFadingExtras)

- (void)fadeToBlack;
- (void)fadeToBlackInSeconds:(float)seconds;
- (void)fadeToRed;
- (void)fadeToRedInSeconds:(float)seconds;
- (void)fadeToGreen;
- (void)fadeToGreenInSeconds:(float)seconds;
- (void)fadeToBlue;
- (void)fadeToBlueInSeconds:(float)seconds;
- (void)fadeToCyan;
- (void)fadeToCyanInSeconds:(float)seconds;
- (void)fadeToYellow;
- (void)fadeToYellowInSeconds:(float)seconds;
- (void)fadeToMagenta;
- (void)fadeToMagentaInSeconds:(float)seconds;
- (void)fadeToOrange;
- (void)fadeToOrangeInSeconds:(float)seconds;
- (void)fadeToPurple;
- (void)fadeToPurpleInSeconds:(float)seconds;
- (void)fadeToBrown;
- (void)fadeToBrownInSeconds:(float)seconds;

@end

