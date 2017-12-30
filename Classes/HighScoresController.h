/* HighScoresController */

#import <Foundation/Foundation.h>
#define SCORESINLIST 15

@interface HighScoresController : NSObject
{
    NSString *recordsFile;
    NSMutableArray *records;
}
- (int)checkWhereScoreShouldGo:(int)score;
- (void)addEntryWithName:(NSString *)name score:(int)score index:(int)placement;
- (void)saveHighScores;
- (IBAction)clearHighScores:(id)sender;
- (NSMutableArray *)scoreEntry;
- (BOOL)containsEntryOfName:(NSString *)aName;
+ (id)sharedInstance;
@end