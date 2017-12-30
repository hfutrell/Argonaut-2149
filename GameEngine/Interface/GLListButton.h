//
//  GLListButton.h
//  Argonaut
//
//  Created by Holmes Futrell on Mon Aug 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLButton.h"
#import "GLMatrix.h"

/*List buttons are buttons which represent items in a list.  They will nearly always be in matrices because in the typically case only one item of the list should be selected.  Obviously, they need a controller, and the GLMatrix class functions as that. */

@interface GLListButton : GLButton {

    BOOL selected; //is the button selected?

}

-(BOOL)isSelected;
-(void)setSelected:(BOOL)_isSelected;

@end
