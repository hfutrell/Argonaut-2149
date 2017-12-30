/* VersionCheckController */

#import <Cocoa/Cocoa.h>

@interface VersionCheckController : NSObject
{
    IBOutlet id versionSheet;
    IBOutlet NSWindow *window;
}
- (IBAction)checkForLatestVersion:(id)sender;
@end