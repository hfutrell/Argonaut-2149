//
//  GLMatrix.h
//  Argonaut
//
//  Created by Holmes Futrell on Tue Aug 19 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLInterfaceObject.h"

@interface GLMatrix : GLInterfaceObject {

    id selectedCell;
    unsigned int selectedIndex;
    id selectTarget,deselectTarget;
    SEL cellSelected,cellDeselected;

}
-(void)setSelectedCell:(id)aCell;
-(void)setSelectedIndex:(int)index;

-(void)deselect;

//selecting previous and next cell
-(void)selectUp;
-(void)selectDown;

//accessor methods
-(void)setSelected:(SEL)selector target:(id)target;
-(void)setDeselected:(SEL)selector target:(id)target;
-(void)nKeyDown:(NSNotification *)theNotification;
-(id)selectedCell;
-(unsigned int)selectedIndex;
//-(void)keyDown:(NSEvent *)theEvent;

@end
