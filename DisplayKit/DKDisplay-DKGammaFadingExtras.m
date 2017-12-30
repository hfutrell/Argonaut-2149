//---------------------------------------------------------------------------------------
//  DKDisplay.m
//
//  Author(s):		Brian Christensen <brian@zobs.net>
//  	who is (are) hereby known as "The Author(s)".
//
//  Description:	Some convience methods for performing gamma fades to various
//			colors. The interface is defined in the "DKDisplay.h" file.
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

@implementation DKDisplay (DKGammaFadingExtras)

- (void)fadeToBlack
{
    [self fadeToBlackInSeconds:fadeSeconds];
}

- (void)fadeToBlackInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0] inSeconds:seconds];
}

- (void)fadeToRed
{
    [self fadeToRedInSeconds:fadeSeconds];
}

- (void)fadeToRedInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor redColor] inSeconds:seconds];
}

- (void)fadeToGreen
{
    [self fadeToGreenInSeconds:fadeSeconds];
}

- (void)fadeToGreenInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor greenColor] inSeconds:seconds];
}

- (void)fadeToBlue
{
    [self fadeToBlueInSeconds:fadeSeconds];
}

- (void)fadeToBlueInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor blueColor] inSeconds:seconds];
}

- (void)fadeToCyan
{
    [self fadeToCyanInSeconds:fadeSeconds];
}

- (void)fadeToCyanInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor cyanColor] inSeconds:seconds];
}

- (void)fadeToYellow
{
    [self fadeToYellowInSeconds:fadeSeconds];
}

- (void)fadeToYellowInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor yellowColor] inSeconds:seconds];
}

- (void)fadeToMagenta
{
    [self fadeToMagentaInSeconds:fadeSeconds];
}

- (void)fadeToMagentaInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor magentaColor] inSeconds:seconds];
}

- (void)fadeToOrange
{
    [self fadeToOrangeInSeconds:fadeSeconds];
}

- (void)fadeToOrangeInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor orangeColor] inSeconds:seconds];
}

- (void)fadeToPurple
{
    [self fadeToPurpleInSeconds:fadeSeconds];
}

- (void)fadeToPurpleInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor purpleColor] inSeconds:seconds];
}

- (void)fadeToBrown
{
    [self fadeToBrownInSeconds:fadeSeconds];
}

- (void)fadeToBrownInSeconds:(float)seconds
{
    [self fadeToColor:[NSColor brownColor] inSeconds:seconds];
}

@end
