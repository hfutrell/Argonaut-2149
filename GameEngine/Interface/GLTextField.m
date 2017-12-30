//
//  GLTextField.m
//  Argonaut
//
//  Created by Holmes Futrell on Tue Aug 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLTextField.h"


@implementation GLTextField

-(void)setEditable:(BOOL)_isEditable {
   
    if (isEditable != _isEditable){
    
        isEditable = _isEditable;
        
        if (isEditable){
            [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(keyDown:)
                name:@"KeyDown" object: nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] removeObserver: self name:@"KeyDown" object: nil];
        }
    
    }
}

-(BOOL)isEditable{
    return isEditable;
}

-(void)setTextColor:(NSColor *)_textColor {
    if (textColor) [textColor release];
    textColor = [_textColor retain];
}

-(NSColor *)textColor {
    return textColor;
}

-(NSString *)string {
    return string;
}
-(NSString *)stringValue {
    return [NSString stringWithString: string];
}

-(void)setString:(NSString *)_string {
    [string setString: _string];
    [self truncateToMaxLength];
}

-(void)setMaxLength:(int)_maxLength{
    maxLength = _maxLength;
    [self truncateToMaxLength];
}

-(unsigned int)maxLength {
    return maxLength;
}

-(void)setFont:(GLFont *)_font{
    if (font) [font release];
    font = [_font retain];
}

-(GLFont *)font{
    return font;
}

//aligning the text
-(void)alignCenter {
    alignment = NSCenterTextAlignment;
}

-(void)alignLeft {
    alignment = NSLeftTextAlignment;
}

-(void)alignRight {
    alignment = NSRightTextAlignment;
}

-(NSTextAlignment)alignment {
    return alignment;
}

-(void)setAlignment:(NSTextAlignment)_alignment {
    alignment = _alignment;
}

-(id)initWithFrame:(NSRect)_frame
            font:(GLFont *)_font
            string:(NSString *)_string {
 
    self = [super init];
    [self setFrame: _frame];
    [self setFont: _font];
    
    string = [[NSMutableString alloc] init];
    if (_string) [self setString: _string];
    
	
    alignment = NSLeftTextAlignment;
    isEditable = NO;
    
    return self;
                
}

-(void)truncateToMaxLength {
    if (maxLength && [string length] > maxLength) [string deleteCharactersInRange:NSMakeRange([string length]-1,[string length]-[self maxLength])];
}

-(void)display {
    
    //don't bother drawing if you shoudn't;
    if (![self shouldDisplay]) return;

    glPushMatrix();
        
    //[self translate];
        
    NSPoint pos = [self absolutePosition];
    NSPoint printingPosition;

    if(scissorTest){
        glEnable(GL_SCISSOR_TEST);
        glScissor([self frame].origin.x, [self frame].origin.y, 800-[self frame].size.width, 600-[self frame].size.height);
    }

    if (![self enabled]) glColor4f(1.0f,1.0f,1.0f,0.3f);
    
    switch( alignment ){ //text is left aligned
        case NSLeftTextAlignment:
            [font printAtX: pos.x y: pos.y string: [string cString]];
            break;
        case NSCenterTextAlignment: //text is centered
            printingPosition.x = pos.x + ([self frame].size.width / 2.0)-([font charSpacing]*[string length]) / 2.0;
            printingPosition.y = pos.y;
            [font printAtX: printingPosition.x y: printingPosition.y string: [string cString]];
            break;
        case NSRightTextAlignment: //text is right aligned
            printingPosition.x = pos.x + ([self frame].size.width)-([font charSpacing]*[string length]);
            printingPosition.y = pos.y;
            [font printAtX: printingPosition.x y: printingPosition.y string: [string cString]];
            break;
        default:
            NSLog(@"Text Field: Invalid alignment mode");
            break;
    }
    
    glDisable(GL_SCISSOR_TEST);

    [super display];
    
    if (![self enabled]) glColor4f(1.0f,1.0f,1.0f,1.0f);

    
    glPopMatrix();

}

-(void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
    [font release];
    //[string release];
    [super dealloc];

}

- (void) keyDown:(NSNotification *)theNotification {

    NSEvent *theEvent = [theNotification object];
    
    if ([self isEditable] && [self shouldDisplay]) {
    
        //filter out junk keys (ie control, option, command, help, f-keys)
        if ([theEvent modifierFlags] & ( NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSHelpKeyMask | NSFunctionKeyMask)){
            return;
        }
    
        unichar unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
    
        switch( unicodeKey )
        {
            case NSUpArrowFunctionKey:
            case NSDownArrowFunctionKey:
            case NSLeftArrowFunctionKey:
            case NSRightArrowFunctionKey:
                break;
            case NSDeleteCharacter:
                [self deleteLastCharacter];
                break;
            case 13: //this is the return key
                if ([self selector] && target) [target performSelector: (SEL)selector withObject: self];
                break;
            default:
                [self addString: [theEvent characters]];
                break;
        }
    }
}  

-(void)addString:(NSString *)_string {
    [string appendString: _string];
    [self truncateToMaxLength];
}

-(void)setScissorTest:(BOOL)_scissorTest{
    scissorTest=_scissorTest;
}

-(void)deleteLastCharacter {

    if ([string length] > 0){

        NSRange range;
        range.location = [string length]-1;
        range.length = 1;
        [string deleteCharactersInRange: range];
        
    }
}

-(void)setTarget:(id)_target selector:(SEL)_selector {
    target = _target;
    selector = (SEL)_selector;
}

-(SEL)selector{
    return (SEL)selector;
}
-(id)target {
    return target;
}

@end

