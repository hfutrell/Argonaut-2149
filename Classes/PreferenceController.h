//
//  PreferenceController.h
//  Spirographx
//
//  Created by Holmes Futrell on Mon Feb 17 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//
//last edited 11/31/03

#import <Cocoa/Cocoa.h>

#define horizontalResolution [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"horizontalResolution"] intValue]
#define verticalResolution [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"verticalResolution"] intValue]

@interface PreferenceController : NSObject {

    NSString *prefsFile;
    NSMutableDictionary *prefs;
    NSMutableDictionary *prefsFromFile;

}

-(void) initPrefsFile;
-(void) savePrefs;

//returns display modes of 16 bits or more which the computer supports
-(NSArray *)validDisplayModes;
//returns the object in the preference dictionary for the given key
-(id)prefForKey:(NSString *)key;
-(void)setObject:(id)object forKey:(NSString *)key;
+(id)sharedInstance;
-(void)setObjectAndTakeEffect:(id)object forKey:(NSString *)key;
-(void)setObjectButNeverSave:(id)object forKey:(NSString *)key;

@end
