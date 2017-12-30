//
//  Level.m
//  Argonaut
//
//  Created by Holmes Futrell on Fri Aug 01 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#import "Game.h"

#define displayX 800
#define displayY 600

@implementation Level

+(id)levelOfNumber:(int)number{
    Level *level = [Level levelOfName: [NSString stringWithFormat:@"level%d.txt", number]];
    if (level) return level;
    return [[Level alloc] buildLevelOfNumber: number];
}

+(id)levelOfName:(NSString *)resource{
    
    NSLog(@"Loading %@",resource);
    
    NSString *path = [ NSString stringWithFormat:@"%@/data/levels/%@", [[NSBundle mainBundle] resourcePath], resource ];
    NSURL *url = [NSURL fileURLWithPath: path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        return [[[self alloc] init] loadDataWithURL: url];
    }
    return nil;
    
}

-(id)buildLevelOfNumber:(int)number {
    
    //NSLog(@"Building level of number %d",number);
    
    self = [self init];
    levelStrings = [[NSMutableArray alloc] init];
    
    [levelStrings addObject:@"wait 1"];
    [levelStrings addObject:[NSString stringWithFormat:@"Play Music %d",[Randomness randomInt: 0 max: 2]]];
    [levelStrings addObject:@"set title 120"];
    [levelStrings addObject:[NSString stringWithFormat:@"Level %d",number+1]];

    BOOL hasGatherBots = ((number > 1) ? [Randomness randomBool] : NO);
    BOOL hasPirates = ((number > 2) ? [Randomness randomBool] : NO);
	BOOL hasDreads = ((number > 11) ? [Randomness randomBool] : NO);
    BOOL hasHugeAsteroids = ((number > 3) ? [Randomness randomBool] : NO);
    BOOL hasArgonauts = ((number > 4) ? ([Randomness randomInt: 0 max: 4]==3) : NO);
    
    float numberOfSmall = [Randomness randomInt: 1 max: number+4];
    float numberOfMedium = [Randomness randomInt: 1 max: number+4];
    float numberOfLarge = [Randomness randomInt: 1 max: number+4];
    float numberOfHuge = hasHugeAsteroids ? [Randomness randomInt: 1 max: (number/3)+1] : 0;
    float numberOfPirates = hasPirates ? [Randomness randomInt: 1 max: (number/2)+1] : 0;
	float numberOfDreads = hasDreads ? [Randomness randomInt: 1 max: (number/4)+1] : 0;
    float numberOfArgonauts = hasArgonauts ? [Randomness randomInt: 1 max: (number/3)+1] : 0;
    
    if (hasGatherBots){
        [levelStrings addObject:@"On Notification Crystal_Spawned self doAction maybeSpawnGatherBot"];
    }
    
    int i;
    for (i=0;i<numberOfSmall;i++){
        [levelStrings addObject:@"Asteroid doAction spawnSmall"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 1]]];
    }
    for (i=0;i<numberOfMedium;i++){
        [levelStrings addObject:@"Asteroid doAction spawnMedium"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 2]]];
    }
    for (i=0;i<numberOfLarge;i++){
        [levelStrings addObject:@"Asteroid doAction spawnLarge"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 3]]];
    }
    for (i=0;i<numberOfHuge;i++){
        [levelStrings addObject:@"Asteroid doAction spawnHuge"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 2 max: 4]]];
    }
    for (i=0;i<numberOfArgonauts;i++){
        [levelStrings addObject:@"Argonaut doAction spawn"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 3 max: 5]]];
    }
    
    if (hasPirates){
        
        [levelStrings addObject:@"Play Music 1"];
        [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 30]]];
        for (i=0;i<numberOfPirates;i++){
            [levelStrings addObject:@"Pirate doAction spawn"];
            [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 10]]];
        }
		for (i=0;i<numberOfDreads;i++){
            [levelStrings addObject:@"DreadPirate doAction spawn"];
            [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 10]]];
        }
        [levelStrings addObject:@"On Notification AllPiratesDestroyed Play Music 0"];
        
    }
    
    [levelStrings addObject:@"On Notification AllAsteroidsDestroyed currentLevel doAction beatLevel"];
    
    if (!hasPirates && ([Randomness randomInt: 0 max: 4] == 2) && number > 2) {
        
        if ([Randomness randomBool]) [levelStrings addObject:@"On Notification Crystal_Spawned self doAction maybeSpawnGatherBot"];
        
        [levelStrings addObject:@"set title 120"];
        [levelStrings addObject:@"Crystal Storm!"];
        [levelStrings addObject:@"wait 3"];

        for (i=0;i<[Randomness randomInt: 20 max: 30];i++){
            [levelStrings addObject:@"Crystal doAction spawn"];
            [levelStrings addObject:[NSString stringWithFormat:@"wait %d",[Randomness randomInt: 0 max: 1]]];
        }
        
    }
        
    //NSLog([levelStrings description]);
    currentLine = -1;
    [self nextLine];
    return self;
    
}

-(id)init {

    self = [super init];
    variableDictionary = [NSMutableDictionary new];
    return self;
    
}

-(void)dealloc {

    //NSLog(@"level has been dealloc'd!");
    [variableDictionary release];
    [levelStrings release];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [super dealloc];

}

-(IBAction)parseLine:(id)sender {

    NSLog(@"Parsing line");
    [self doLine: [sender stringValue]];

}

-(Level *)loadDataWithURL:(NSURL *)url {

    //if (levelStrings) [levelStrings release];
    levelStrings = [[[NSString stringWithContentsOfFile: [url path]] componentsSeparatedByString:@"\n"] retain];
    
    //NSLog([levelStrings description]);
    currentLine = -1;
    //filein = fopen([[url path] fileSystemRepresentation], "rt");
    [self nextLine];
    return self;
    
}

-(void)nextLine {

    if (currentLine < (int)[levelStrings count]-1){
    
        currentLine++;
        [self doLine: [levelStrings objectAtIndex: currentLine]];

    }
    
}

-(void)maybeSpawnPirate {    
    if ([Randomness randomFloat: 0 max: 1.0] <= 0.8 && [[Ship sharedSet] count] < 5){        
        [Pirate spawn];
    }
}

-(void)maybeSpawnGatherBot {
    
    if ([Randomness randomFloat: 0 max: 1.0] <= 0.15 && [[Ship sharedSet] count] < 5){
        [GatherBot spawn];
    }

}

-(void)fadeMusic {
    [[ Game SharedInstance ] fadeMusic];
}

+(NSArray *)levelsArray {
    
    NSMutableArray *array = [NSMutableArray new];
    NSString *file;
    NSDirectoryEnumerator *enumerator = [ [NSFileManager defaultManager]
        enumeratorAtPath:[ NSString stringWithFormat:@"%@/levels/", [[NSBundle mainBundle] resourcePath] ] ];
        
    while (file = [enumerator nextObject]) {
    if ([[file pathExtension] isEqualToString:@"txt"])
        [array addObject: file];
    }
    return array;
    
}

-(void)make:(float)timeGoneBy {
    
    timeTillNextLine -= timeGoneBy;
    if (timeTillNextLine < 0) {
        [self nextLine];
    }
    
}

-(void)doLine:(NSString *)line {
    
    //char oneline[255];
    char classCString[255];
    char actionString[255];
    //char conditionCString[255];
    char notificationCString[255];
    //float seconds;
    float value;
    int intValue;
            
    //wait before scanning next line
    if (sscanf([line cString], "wait %f", &value) == 1) {
        timeTillNextLine = value;
        return;
    }
    
    if (sscanf([line cString], "Play Music %d", &intValue) == 1) {
        [[ Game SharedInstance ] playTrack: intValue];
    }
    
   if (sscanf([line cString], "set title %f", &value) == 1) {
   
       currentLine++;
       NSString *realString = [levelStrings objectAtIndex: currentLine];
       [[ Game SharedInstance ] setTitleText: realString time: value];
        
    }
    //simple action statements
    if (sscanf([line cString], "%s doAction %s", classCString, actionString) == 2) {
        id builtClass = [self buildClass: classCString];
        SEL builtSelector = [self buildSelector: actionString]; 
        [builtClass performSelector:builtSelector withObject: nil];
    }
    //action statements with a numeric argument
    if (sscanf([line cString], " %s doAction %s withValue %d", classCString, actionString, &intValue) == 3) {
    
        id builtClass = [self buildClass: classCString];
        SEL builtSelector = [self buildSelector: actionString]; 
        [builtClass performSelector:builtSelector withObject: [NSNumber numberWithInt: intValue]];
        
    }
    if (sscanf([line cString], "On Notification %s %s doAction %s", notificationCString, classCString, actionString) == 3) {
    
        SEL builtSelector = NSSelectorFromString([NSString stringWithCString: actionString]);
        NSString *notificationString = [NSString stringWithCString: notificationCString];
        id builtClass = [self buildClass: classCString];

        [[NSNotificationCenter defaultCenter] addObserver: builtClass
            selector: builtSelector 
            name: notificationString object: nil];
                    
        if (![builtClass respondsToSelector:builtSelector]){
            NSLog(@"class doesn't respond to selector");
        }
    }
    if (sscanf([line cString], "On Notification %s Play Music %d", notificationCString, &intValue) == 2) {
        
        NSString *notificationString = [NSString stringWithCString: notificationCString];        
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(playMusic) 
            name: notificationString object: nil];
        
        nextMusic = intValue;
                
    }
    [self nextLine];

}

-(void)playMusic{
    
    [[ Game SharedInstance ] playTrack: nextMusic];
    
}

-(id)buildClass:(char *)string {

    NSString *classString = [NSString stringWithCString: string];
    id theClass;
    if ([classString isEqual:@"self"] || [classString isEqual:@"currentLevel"]  ){
        return self;
    }
    else{
        return NSClassFromString(classString);
    }
    if (theClass == nil){
        NSLog(@"Level Warning: Class %s not found.", classString);
        return nil;
    }
    
}

-(SEL)buildSelector:(char *)string {

   return NSSelectorFromString([NSString stringWithCString: string]);

}

-(void)beatLevel {

    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"Level Beaten" object: self];

}

@end
