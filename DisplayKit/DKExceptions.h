//---------------------------------------------------------------------------------------
//  DKExceptions.h
//
//  Author(s):		Brian Christensen <brian@zobs.net>
//  	who is (are) hereby known as "The Author(s)".
//
//  Description:	The exceptions raised by the DisplayKit if any errors occur.
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

// DisplayKit exceptions
extern NSString * const DKGetActiveDisplayListFailedException;
extern NSString * const DKDisplayCaptureFailedException;
extern NSString * const DKCaptureAllDisplaysFailedException;
extern NSString * const DKDisplayReleaseFailedException;
extern NSString * const DKReleaseAllDisplaysFailedException;
extern NSString * const DKSetDisplayTransferFailedException;
extern NSString * const DKGetDisplayTransferFailedException;
extern NSString * const DKHideCursorFailedException;
extern NSString * const DKShowCursorFailedException;
extern NSString * const DKMoveCursorToPointFailedException;
extern NSString * const DKDisplayBestModeForParametersFailedException;
extern NSString * const DKDisplaySwitchToModeFailedException;
extern NSString * const DKGetDisplayTransferByTableFailedException;

// Key to get the CGDisplayErr error number from the userInfo of the raised exception
extern NSString * const DKCoreGraphicsErrorNum;
