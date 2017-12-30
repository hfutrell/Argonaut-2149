//
//  GLProgressIndicator.h
//  Argonaut
//
//  Created by Holmes on Sat Aug 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLInterfaceObject.h>

#define TYPE_SINGLE_FRAME 0
#define TYPE_MULTI_FRAME 1

//This class is blatently modeled off of NSProgressIndicator.
//Most methods are the same.

@interface GLProgressIndicator : GLInterfaceObject {

    GLSprite *sprite;

    float minValue,maxValue,floatValue;
    
    int type;

}

//convenience methods
+(id)initWithFrame:(NSRect)_rect
    sprite:(GLSprite *)_sprite;
//accessor methods
-(void)setMinValue:(float)minValue;
-(void)setMaxValue:(float)maxValue;
-(void)incrementBy:(float)amount;
-(void)setFloatValue:(float)value;
-(void)setControlSize:(int)size;
-(float)maxValue;
-(float)minValue;
-(float)floatValue;

//rendering
-(void)setSprite:(GLSprite *)_sprite;

@end
