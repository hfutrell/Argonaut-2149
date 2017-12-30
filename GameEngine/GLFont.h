//
//  GLFont.h
//  Argonaut
//
//  Created by Holmes Futrell on Tue Jul 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLTexture.h>

@interface GLFont : NSObject {

    GLuint  base;    // Font Display List
    GLTexture *fontTexture; //Holds the image for our font
    int xSpacing,ySpacing;
    int charSpacing;
    
}
-(id)initWithResource:(NSString *)resourceName xSpacing:(int)_xSpacing ySpacing:(int)_ySpacing;
-(void)printAtX:(GLint)x y:(GLint)y string:(const char *)string, ...;
-(void) buildFont:(GLTexture *)newTexture xSpacing:(int)_xSpacing ySpacing:(int)_ySpacing;
-(void)readLine:(FILE *)f string:(char *)string;
//accessor methods
-(int)xSpacing;
-(int)ySpacing;
-(int)charSpacing;

@end
