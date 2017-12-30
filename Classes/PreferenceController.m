//Preference Controller.m

#import "PreferenceController.h"

//for sorting the display modes
static int _compareModes(id arg1, id arg2, void *context);

@implementation PreferenceController

static PreferenceController *sharedInstance;

+(id)sharedInstance {
    return !sharedInstance ? sharedInstance = [[PreferenceController alloc] init] : sharedInstance;
}

- (id)init
{	
    prefs = [[NSMutableDictionary alloc] init];
    prefsFromFile = [[NSMutableDictionary alloc] init];
    //NSLog(@"Preference controller awaking init...");
    prefsFile = [[[NSString stringWithString:@"~/Library/Preferences/argoprefs.plist"] stringByExpandingTildeInPath] retain];
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefsFile]){
        NSLog(@"Prefs file doesn't exist, will create new one...");
        [self initPrefsFile];
    }
    [prefs release];
    [prefsFromFile release];
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: prefsFile];
    prefsFromFile = [[NSMutableDictionary alloc] initWithContentsOfFile: prefsFile];

    if (![prefs objectForKey:@"cheats"]) [prefs setObject:[NSNumber numberWithInt:FALSE] forKey:@"cheats"];
    if (![prefsFromFile objectForKey:@"cheats"]) [prefsFromFile setObject:[NSNumber numberWithInt:FALSE] forKey:@"cheats"];
   
	if (![prefs objectForKey:@"samples"]) [prefsFromFile setObject:[NSNumber numberWithInt:0] forKey:@"samples"];
	if (![prefsFromFile objectForKey:@"samples"]) [prefsFromFile setObject:[NSNumber numberWithInt:0] forKey:@"samples"];

    return self;
}

- (void) dealloc {
 
     [prefsFile release];
     [prefs release];
     [prefsFromFile release];
     sharedInstance=nil;
     [super dealloc];
}

- (void) initPrefsFile
{
    //NSLog(@"...Init prefs file");
    [prefs removeAllObjects];
    [prefs setObject: [NSNumber numberWithInt: 800] forKey:@"horizontalResolution"];
    [prefs setObject: [NSNumber numberWithInt: 600] forKey:@"verticalResolution"];
    [prefs setObject: [NSNumber numberWithInt: 32] forKey:@"colorBits"];
    [prefs setObject: [NSNumber numberWithInt: 255] forKey:@"soundVolume"];
    [prefs setObject: [NSNumber numberWithInt: 255] forKey:@"musicVolume"];
    [prefs setObject: [NSNumber numberWithInt: FALSE] forKey:@"fullscreenMode"];
    [prefs setObject: [NSNumber numberWithInt: FALSE] forKey:@"cheats"];
	[prefs setObject: [NSNumber numberWithInt: 0] forKey:@"samples"];

    //note, we don't actually store whether its registered or not in the prefs, because then the user could just hack it
    //pretty easily.  Rather we store the registration number in the file and validate it each time the application opens.
    [self savePrefs];
    
}

- (void) savePrefs
{
    //NSLog(@"Saving prefs");
    [prefs writeToFile:prefsFile atomically:YES];
}

- (NSArray *)validDisplayModes;
{
    unsigned int modeIndex, modeCount;
    NSArray *modes;
    NSMutableArray *displayModes;
    NSDictionary *mode;
    //NSString *description;
    //unsigned int modeWidth, modeHeight, color, refresh, flags;
    int color;
    // Get the list of all available modes
    modes = [(NSArray *)CGDisplayAvailableModes(kCGDirectMainDisplay) retain];
    // Filter out modes that we don't want
    displayModes = [[NSMutableArray alloc] init];
    modeCount = [modes count];
    for (modeIndex = 0; modeIndex < modeCount; modeIndex++) {
        mode = [modes objectAtIndex: modeIndex];
        color = [[mode objectForKey:(NSString *)kCGDisplayBitsPerPixel] intValue];
        if (color < 16)
            continue;
        [displayModes addObject: mode];
    }
    
    // Sort the filtered modes
    [displayModes sortUsingFunction: _compareModes context: NULL];
    return displayModes;
    /* HOW TO GET SOME FACTORS OUT OF THESE DISPLAY MODES
    mode = [displayModes objectAtIndex: modeIndex];
    modeWidth = [[mode objectForKey: (NSString *)kCGDisplayWidth] intValue];
    modeHeight = [[mode objectForKey: (NSString *)kCGDisplayHeight] intValue];
    color = [[mode objectForKey: (NSString *)kCGDisplayBitsPerPixel] intValue];
    refresh = [[mode objectForKey: (NSString *)kCGDisplayRefreshRate] intValue];
    flags = [[mode objectForKey: (NSString *)kCGDisplayIOFlags] intValue];
    description = [NSString stringWithFormat: @"%dx%d", modeWidth, modeHeight];
    */
}

static int _compareModes(id arg1, id arg2, void *context)
{
    NSDictionary *mode1 = (NSDictionary *)arg1;
    NSDictionary *mode2 = (NSDictionary *)arg2;
    int size1, size2;
    
    // Sort first on pixel count
    size1 = [[mode1 objectForKey: (NSString *)kCGDisplayWidth] intValue] *
        [[mode1 objectForKey: (NSString *)kCGDisplayHeight] intValue];
    size2 = [[mode2 objectForKey: (NSString *)kCGDisplayWidth] intValue] *
        [[mode2 objectForKey: (NSString *)kCGDisplayHeight] intValue];
    if (size1 != size2)
        return size1 - size2;
    
    // Then on bit depth
    return (int)[[mode1 objectForKey: (NSString *)kCGDisplayBitsPerPixel] intValue] -
        (int)[[mode2 objectForKey: (NSString *)kCGDisplayBitsPerPixel] intValue];
}


-(id)prefForKey:(NSString *)key {
    
    //NSLog(@"Asked for %@",key);
    id object = [prefsFromFile objectForKey: key];
    if (!object) NSLog(@"Warning, no preference for key %@", key);
    return object;
}

-(void)setObject:(id)object forKey:(NSString *)key {
    [prefs setObject:object forKey:key];
}

-(void)setObjectAndTakeEffect:(id)object forKey:(NSString *)key {
   
    [prefsFromFile setObject:object forKey:key];
    [prefs setObject:object forKey:key];

}

-(void)setObjectButNeverSave:(id)object forKey:(NSString *)key {
    [prefsFromFile setObject:object forKey:key];
}

@end
