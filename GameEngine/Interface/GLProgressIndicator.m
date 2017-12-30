//
//  GLProgressIndicator.m
//  Argonaut
//
//  Created by Holmes on Sat Aug 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLProgressIndicator.h"

@implementation GLProgressIndicator

+(id)initWithFrame:(NSRect)_rect //used for position and width
    sprite:(GLSprite *)_sprite { //the graphic used
    
    GLProgressIndicator *newInstance = [GLProgressIndicator new];
    [newInstance setFrame: _rect];
    [newInstance setSprite: _sprite];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Item Loaded" object: newInstance];

    return newInstance;
    
}

-(id)init {
    
    [super init];
    floatValue = 0;
    minValue = 0;
    maxValue = 0;
    return self;

}

//rendering
-( void )display {

    //the percent done the progress is (and prevent divide by zero error)
    float percent = ([self floatValue]-minValue)/(maxValue-minValue);
    
    //the number of pixels the bar should be at its percent
    int pixelLength = percent * frame.size.width;
    //how large the stretched middle section should be
    int pixelStretch = pixelLength - [[sprite frameNumber: 0] imageWidth] - [[sprite frameNumber: 2] imageWidth];
    	
    if (maxValue <= 0 || percent <= 0 ) pixelStretch = -1; //don't draw
    
    //NSLog(@"float value = %f, max = %f, min = %f, percent = %f, pixelLength = %f, pixelStretch = %f", floatValue, maxValue, minValue, percent, pixelLength, pixelStretch);
    
    if (pixelStretch >= 0 ){ //if theres no middle section, we shouldn't draw
    
        glPushMatrix();

            [self translate];

            //draw the left end graphic
            [sprite drawFrame: 0];
            glTranslatef([[sprite frameNumber: 0] imageWidth],0.0,0.0);
            
            //draw the stretched middle graphic
            glPushMatrix();
                                        
                NSSize size;
                size.width = pixelStretch;
                size.height = [[sprite frameNumber: 1] imageHeight];                
                [sprite drawFrame: 1 size: size];
            
            glPopMatrix();
            
            //draw the right end graphic
            glTranslatef(pixelStretch,0.0,0.0);
            [sprite drawFrame: 2];
        
        glPopMatrix();

    }
    [super display];
}

//accessor methods

-(void)setSprite:(GLSprite *)_sprite {

    [sprite release];
    
    sprite = [_sprite retain];
    switch ([sprite numFrames]){
    
        case 1:
        
            type = TYPE_SINGLE_FRAME;
            break;
            
        case 3:
        
            type = TYPE_MULTI_FRAME;
            break;

        default:
        
            NSLog(@"Error, %d images don't work with progress bars", [sprite numFrames]);
            break;

    }

}

-(void)dealloc {

    [sprite release];
    [super dealloc];

}

-(void)setMinValue:(float)_minValue{
    minValue = _minValue;
}
-(void)setMaxValue:(float)_maxValue{
    maxValue = _maxValue;
}
-(void)incrementBy:(float)amount{
    floatValue += amount;
}
-(void)setFloatValue:(float)value{
    floatValue = value;
}
-(void)setControlSize:(int)size{
    frame.size.width = size;
}
-(float)maxValue{
    return maxValue;
}
-(float)minValue{
    return minValue;
}
-(float)floatValue{
    return floatValue > maxValue ? maxValue : floatValue;
}

@end
