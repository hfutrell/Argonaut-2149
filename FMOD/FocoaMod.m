//
//  FocoaMod.m
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 08 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "FocoaMod.h"
#import "fmod_errors.h"

@implementation FocoaMod


+(void)driverCapabilities {

    //FMOD_ErrorString(nil);
    unsigned int caps = 0;
    FSOUND_GetDriverCaps(FSOUND_GetDriver(), &caps);
    
    printf("---------------------------------------------------------\n");	
    printf("FMOD Driver capabilities\n");
    printf("---------------------------------------------------------\n");	
    if (!caps)
    printf("- This driver will support software mode only.\n  It does not properly support 3D sound hardware.\n");
    if (caps & FSOUND_CAPS_HARDWARE)
    printf("- Driver supports hardware 3D sound!\n");
    if (caps & FSOUND_CAPS_EAX2)
    printf("- Driver supports EAX 2 reverb!\n");
    if (caps & FSOUND_CAPS_EAX3)
    printf("- Driver supports EAX 3 reverb!\n");
    printf("---------------------------------------------------------\n");	

}

/*FSOUND_LOOP_OFF     
 FSOUND_LOOP_NORMAL  
 FSOUND_LOOP_BIDI    
 FSOUND_HW3D
 FSOUND_2D
 FSOUND_STREAMABLE   
 FSOUND_LOADMEMORY   
 FSOUND_LOADRAW          
 FSOUND_MPEGACCURATE     
*/
-(id)initWithResource:(NSString *)resourceName mode:(unsigned int)inputMode {
  
    NSString *absolutePath = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resourceName ];
    //FSOUND_FREE, stick it wherever it fits
    //last argument left 0 because its read from the disk
    sample = FSOUND_Sample_Load(FSOUND_FREE, [absolutePath fileSystemRepresentation], inputMode, 0, 0);

    if (!sample) {
        NSLog(@"FMOD Sample %@: %s\n", resourceName, FMOD_ErrorString(FSOUND_GetError()));
        FSOUND_Sample_Free(sample);
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Item Loaded" object: self];
    return self;
    
}

/* Sets a sample's mode.  This can only be FSOUND_LOOP_OFF,FSOUND_LOOP_NORMAL, FSOUND_LOOP_BIDI or FSOUND_2D. */
-(BOOL)setMode:(int)newMode {
    return FSOUND_Sample_SetMode(sample, newMode);
}

-(void)setMinDistance:(float)minDistance maxDistance:(float)maxDistance {
    FSOUND_Sample_SetMinMaxDistance(sample, minDistance, maxDistance);
}

//plays the sound and doesn't do much special
-(void)play {
   myChannel = FSOUND_PlaySound(FSOUND_FREE, sample);
}

//the extended version of playing a sound.  Fitter, happier, more productive.
/*ew functionality includes the ability to start the sound paused.  This allows attributes
 of a channel to be set freely before the sound actually starts playing, until FSOUND_SetPaused(FALSE) is used.
 Also added is the ability to associate the channel to a specified DSP unit.  This allows
 the user to 'group' channels into seperate DSP units, which allows effects to be inserted
 between these 'groups', and allow various things like having one group affected by reverb (wet mix) and another group of 
 channels unaffected (dry).  This is useful to seperate things like music from being affected
 by DSP effects, while other sound effects are.
 */
-(void)playExtended {
   myChannel = FSOUND_PlaySoundEx(FSOUND_FREE, sample, NULL, FALSE);
}

-(void)pause {
   FSOUND_SetPaused(myChannel, TRUE);
}

-(void)unpause {
  FSOUND_SetPaused(myChannel, FALSE);
}

-(void)stop {
    FSOUND_StopSound(myChannel);
}

-(void)togglepause {
    FSOUND_SetPaused(myChannel, !FSOUND_GetPaused(myChannel));
}

-(void)playExtendedWithXpos:(float)xpos yPos:(float)ypos zPos:(float)zpos xvel:(float)xvel yvel:(float)yvel zvel:(float)zvel {
    
    float pos[3] = { xpos, ypos, zpos };
    float vel[3] = { xvel, yvel, zvel };
    
    //in this version we start the sound paused so we can set an attribute (3d position and velocity) first before playing it;
    myChannel = FSOUND_PlaySoundEx(FSOUND_FREE, sample, NULL, TRUE);
    FSOUND_3D_SetAttributes(myChannel, pos, vel);
    FSOUND_SetPaused(myChannel, FALSE);
    
}

-(unsigned int)channel {
    return myChannel;
}


//volume is a number between 0 and 255
-(void)setVolume:(float)volume {

   FSOUND_SetVolume(myChannel, volume);

}

-(void)dealloc {
    FSOUND_Sample_Free(sample);
    //FSOUND_Sample_Free(stream);
    [super dealloc];
}

-(void)setFrequency:(int)frequency{
    FSOUND_SetFrequency([self channel],frequency);
}

//this needs to be called first
+(BOOL)initFMODWithMixRate:(int)mixrate mixChannels:(int)maxSoftwareChannels flags:(unsigned int)flags {

    if (!FSOUND_Init(mixrate, maxSoftwareChannels, flags)) {
        printf("Init: %s\n", FMOD_ErrorString(FSOUND_GetError()));
        return FALSE;
    }
    return TRUE;
}

//set the listiners position in 3D space
+(void)setListenerXPos:(float)xpos
    yPos:(float)ypos
    zPos:(float)zpos
    xVel:(float)xvel
    yVel:(float)yvel
    zVel:(float)zvel
    rotation:(float)rot {
    
    float listenerpos[3] = {xpos,ypos,zpos};
    float vel[3]	 = {xvel,yvel,zvel};
    
    FSOUND_3D_Listener_SetAttributes(listenerpos, vel, cos(rot), sin(rot), 0.0, 0.0, 1.0, 0.0);
}

//this must be called once per frame
+(void)update3DSound {
    FSOUND_Update();
}

+(void)setDistanceFactor:(float)scale {
    
    FSOUND_3D_SetDistanceFactor(scale);

}

//the doppler effect
//1.0 is the default where the spead of sound is 340.0 units per second
+(void)setDopplerFactor:(float)scale {
    FSOUND_3D_SetDopplerFactor(scale);
}

+(void)freeAllSounds {
    //closes the fsound system and frees all samples that are contained in its index
    FSOUND_Close();
}

-(BOOL)isPlaying {
    return FSOUND_IsPlaying([self myChannel]);
}

-(int)myChannel {
    return myChannel;
}

@end

@implementation FocoaStream

-(FocoaStream *)initWithResource:(NSString *)resourceName mode:(unsigned int)inputMode {
    
    NSString *absolutePath = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resourceName ];
    
    stream = FSOUND_Stream_Open((const char*)[absolutePath fileSystemRepresentation], inputMode, 0, 0);    
    if (!stream) {
        NSLog(@"FMOD Sample %@: %s\n", resourceName, FMOD_ErrorString(FSOUND_GetError()));
        FSOUND_Sample_Free(stream);
        return nil;
    }    
    return self;
    
}

-(void)playExtendedWithXpos:(float)xpos yPos:(float)ypos zPos:(float)zpos xvel:(float)xvel yvel:(float)yvel zvel:(float)zvel {
    
    NSLog(@"play extended not supported by streamables right now");
}

-(void)playExtended {
    NSLog(@"play extended not supported by streamables right now");
}

-(BOOL)setMode:(int)newMode {
    NSLog(@"set mode not stream no!");
    return FALSE;
}

-(void)play {
   myChannel = FSOUND_Stream_Play(FSOUND_FREE, stream);   
}

-(void)stop {
	FSOUND_Stream_Stop(stream);   
}

-(void)dealloc {
    FSOUND_Stream_Close(stream);
    [super dealloc];
}

-(void)setMinDistance:(float)minDistance maxDistance:(float)maxDistance {
    NSLog(@"set min max distance won't work here");
    //FSOUND_Sample_SetMinMaxDistance(stream, minDistance, maxDistance);
}

@end

