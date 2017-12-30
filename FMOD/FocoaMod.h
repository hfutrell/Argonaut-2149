//
//  FocoaMod.h
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 08 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/carbon.h>

/*fmod files*/
#import "fmod.h"
//#import <fmod_errors.h>
#import <wincompat.h>

/*FocoaMod is a Cocoa wrapper for FMOD that I wrote.  It groups FMOD sounds with their functions as objects. */
//see fmod.org for full FMOD documentation.
@interface FocoaMod : NSObject {

    FSOUND_SAMPLE *sample; //the sound data
    int myChannel; //the channel the sound is/will be playing in

}
-(void)setFrequency:(int)frequency;
-(void)setVolume:(float)volume;
-(id)initWithResource:(NSString *)resourceName mode:(unsigned int)inputMode;
-(BOOL)setMode:(int)newMode;
-(void)setMinDistance:(float)minDistance maxDistance:(float)maxDistance;
-(void)play;
-(void)playExtended;
-(void)pause;
-(void)unpause;
-(void)togglepause;
-(unsigned int)channel;
-(void)setVolume:(float)volume;
-(void)playExtendedWithXpos:(float)xpos yPos:(float)ypos zPos:(float)zpos xvel:(float)xvel yvel:(float)yvel zvel:(float)zvel;
-(void)dealloc;
+(void)driverCapabilities;
+(BOOL)initFMODWithMixRate:(int)mixrate mixChannels:(int)maxSoftwareChannels flags:(unsigned int)flags;
+(void)setListenerXPos:(float)xpos
    yPos:(float)ypos
    zPos:(float)zpos
    xVel:(float)xvel
    yVel:(float)yvel
    zVel:(float)zvel
    rotation:(float)rot;

+(void)update3DSound;
+(void)setDistanceFactor:(float)scale;
+(void)setDopplerFactor:(float)scale;
+(void)freeAllSounds;
-(void)stop;
-(BOOL)isPlaying;
-(int)myChannel;

@end

@interface FocoaStream : FocoaMod {
    FSOUND_STREAM *stream;
}
@end
