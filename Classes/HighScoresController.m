#import "HighScoresController.h"

static HighScoresController *sharedInstance;

@implementation HighScoresController

    -(void)dealloc {
		[recordsFile release];
		[records release];
		sharedInstance=nil;
		[super dealloc];
    }

    +(id)sharedInstance {
       return  sharedInstance ? sharedInstance : [[HighScoresController alloc] init];
    }

    - (NSString *)description {
        return [[self scoreEntry] description];
    }

    - (int)checkWhereScoreShouldGo:(int)score
    {
        int n;
        //NSLog(@"Placing amongst %d entries",[records count]);
        for (n=0;n<[records count];n++)
        {
            if (score > [[[records objectAtIndex: n] objectForKey:@"score"] intValue])
            {
                //printf("Score places %d.\n",n);
                return n;
            }
        }
        //printf("Score doesn't place.\n");
        return -1;
    }
    
    - (void)addEntryWithName:(NSString *)name score:(int)score index:(int)placement
    {
        if (placement >= 0 ){
    
            NSDictionary *entryToAdd = 
                [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", 
                [NSNumber numberWithInt:score], @"score", nil];
    
            //NSLog(@"Adding High Score entry");
            [records insertObject: entryToAdd atIndex: (int)placement];
            [records removeLastObject];
            [self saveHighScores];
        
        }
    }
    
    - (void)saveHighScores
    {
        //NSLog(@"Saving scores to %@\n",recordsFile);
        [records writeToFile:recordsFile atomically:YES];
    }
    
    - (IBAction) clearHighScores:(id)sender    
    {
        int n;
        //NSLog(@"Clearing High-Scores\n");
        [records removeAllObjects];
        for (n=0;n<SCORESINLIST;n++)
        {
             NSDictionary *newEntry = 
                [NSDictionary dictionaryWithObjectsAndKeys: @"Nobody", @"name",
                [NSNumber numberWithInt: 100*(SCORESINLIST-n)], @"score", nil];
                
            [records insertObject: newEntry atIndex: n];
        }
        [self saveHighScores];
    }
    
    - (id)init
    {
        self = [super init];
        recordsFile = [[[NSString stringWithString:@"~/Library/Preferences/ArgonautScores.plist"] stringByExpandingTildeInPath] retain];
        records = [[NSMutableArray alloc] initWithContentsOfFile: recordsFile];
        if (!records)
        {
            records=[[NSMutableArray alloc] init];
            [self clearHighScores:self];
        }
        return self;
    }
    
    -(NSMutableArray *)scoreEntry
    {
        return records;
    }

    -(BOOL)containsEntryOfName:(NSString *)aName {
    int i;
        for (i=0;i<[records count];i++){
            if ([[[records objectAtIndex: i] objectForKey:@"name"] isEqual: aName]) return TRUE;
        }
        return FALSE;
    }
    
@end
