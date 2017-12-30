#import "VersionCheckController.h"

@implementation VersionCheckController

- (IBAction)checkForLatestVersion:(id)sender
{
    NSString *currVersionNumber = [[[NSBundle bundleForClass:[self class]]
        infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:
        [NSURL URLWithString:@"http://homepage.mac.com/solidmag/humiversion.xml"]];
        
    NSString *latestVersionNumber = [productVersionDict valueForKey:@"productone"];
    
    if (!latestVersionNumber)
    {
       
        printf("You're either not on the internet, or the link is broken\n");
        
        NSBeginAlertSheet(
            @"Error:  Could not find version file on server.",
            @"OK", nil, nil,
            window,
            self,
            @selector(sheetDidEndShouldDelete:returnCode:contextInfo:),
            NULL,
            window,
            @"Either you are not connected to the internet, or the file is missing on the server.",
            nil);        
    }
    else if ([latestVersionNumber isEqualTo: currVersionNumber])
    {
        printf("Its up to date\n");
        NSBeginAlertSheet(
            @"Your software is up to date",
            @"OK", nil, nil,
            window,
            self,
            @selector(sheetDidEndShouldDelete:returnCode:contextInfo:),
            NULL,
            window,
            @"Your version (%@) is the newest availible.",
            currVersionNumber);
    }
    else
    {
        printf("Its not up to date\n");
        NSBeginAlertSheet(
            @"New Version Availible",
            @"Download", @"Cancel", nil,
            window,
            self,
            @selector(downloadSheetDidEnd:returnCode:contextInfo:),
            NULL,
            window,
            @"Version %@ is now availible.  Would you like to download it?",
            latestVersionNumber);
    }
}

- (void)sheetDidEndShouldDelete: (NSWindow *)sheet
        returnCode: (int)returnCode
        contextInfo: (void *)contextInfo
{
    //put stuff here
}

- (void)downloadSheetDidEnd: (NSWindow *)sheet
        returnCode: (int)returnCode
        contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        printf("User has selected download.\n");
        [[NSWorkspace sharedWorkspace] openURL:[NSURL
            URLWithString:@"http://homepage.mac.com/solidmag/humi/"]];
    }
    else
    {
        printf("User has canceled download.\n");
    }
}


@end
