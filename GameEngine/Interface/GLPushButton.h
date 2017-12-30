//
//  GLPushButton.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLButton.h"

/*Push buttons are buttons which merely are pushed and perform their selectors.  They can also be disabled, enabled, and have other selectors like enter and exit selectors*/

@interface GLPushButton : GLButton {

}
-(void)mouseDown:(NSEvent *)theEvent;
-(void)mouseUp:(NSEvent *)theEvent;
-(void)handleMouseMove;



@end
