//
//  GLMatrix.m
//  Argonaut
//
//  Created by Holmes Futrell on Tue Aug 19 2003.
//  Copyright (c) 2003 Holmes Futrell. All rights reserved.
//

#import "GLMatrix.h"
#import <GLListbutton.h>

@implementation GLMatrix

-(void)setSelectedCell:(id)aCell{
    int i;
    for (i=0;i<[children count];i++){
        //if the cell in the array is equal to the cell sent, select it, else make sure its not selected
        if ([children objectAtIndex: i] == aCell){
        
            selectedCell = [children objectAtIndex: i];
            selectedIndex = i;
            [(GLListButton*)[children objectAtIndex: i] setSelected: YES];
            if (cellSelected) [selectTarget performSelector: cellSelected];
        }
        else {
            [(GLListButton*)[children objectAtIndex: i] setSelected: NO];
        }
    }
}

-(void)setSelectedIndex:(int)index{
    [self setSelectedCell:[[self children] objectAtIndex: index]];
}

- (id) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(nKeyDown:)
        name:@"KeyDown" object: nil];
    
    return self;
}

- (void) dealloc {
   // [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [super dealloc];
}

-(void)enable {
 
    [self setSelectedCell:[self selectedCell]];
    [super enable];
}

- (void)nKeyDown:(NSNotification *)theNotification {

    NSEvent *theEvent = [theNotification object];

     if ([self shouldDisplay] && ![self isZooming] && [self selectedCell] && [self enabled]){

        unichar unicodeKey;
        unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
        switch( unicodeKey )
        {
            case NSUpArrowFunctionKey:
                [self selectUp];
                break;
            case NSDownArrowFunctionKey:
                [self selectDown];
                break;
        }
    
    }
}

-(void)selectUp {

    if (selectedIndex > 0){
        [self setSelectedCell: [children objectAtIndex: selectedIndex-1] ];
    }
    
}
-(void)selectDown {

    unsigned int nextCellIndex = selectedIndex+1 > [children count]-1 ? [children count]-1 : selectedIndex+1;
    [self setSelectedCell: [children objectAtIndex: nextCellIndex] ];


}

-(void)setSelected:(SEL)selector target:(id)target {
    cellSelected = selector;
    selectTarget = target;
}

-(void)setDeselected:(SEL)selector target:(id)target {
    cellDeselected = selector;
    deselectTarget = target;
}

-(id)selectedCell{
    return selectedCell;
}
-(unsigned int)selectedIndex{
    return selectedIndex;
}

-(void)deselect {

    int i;
    for (i=0;i<[children count];i++){
        [(GLListButton*)[children objectAtIndex: i] setSelected: NO];
    }
    if (cellDeselected) [deselectTarget performSelector: cellDeselected];

}

@end
