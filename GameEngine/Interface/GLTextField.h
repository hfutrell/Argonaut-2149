//
//  GLTextField.h
//  Argonaut
//
//  Created by Holmes Futrell on Tue Aug 26 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLInterfaceObject.h>

@interface GLTextField : GLInterfaceObject {

    BOOL isEditable,clippedToFrame,scissorTest;
    GLFont *font;
    NSMutableString *string;
    NSColor *textColor;
    NSTextAlignment alignment;
    SEL selector;
    id target;
    
    unsigned int maxLength;

}
-(void)setEditable:(BOOL)_isEditable;
-(BOOL)isEditable;
-(void)setTextColor:(NSColor *)_textColor;
-(NSColor *)textColor;
-(NSString *)string;
-(void)setString:(NSString *)string;
-(void)setFont:(GLFont *)_font;
-(GLFont *)font;
-(void)deleteLastCharacter;

/*NSLeftTextAlignment
Text is visually left aligned.
NSRightTextAlignment
Text is visually right aligned.
NSCenterTextAlignment
Text is visually center aligned.
NSJustifiedTextAlignment
Text is justified.
NSNaturalTextAlignment
Use the natural alignment of the text's script.*/
-(void)alignCenter;
-(void)alignLeft;
-(void)alignRight;
-(NSTextAlignment)alignment;

-(void)setScissorTest:(BOOL)_scissorTest;

-(id)initWithFrame:(NSRect)frame
            font:(GLFont *)font
            string:(NSString *)string;
            
-(void)addString:(NSString *)_string;

-(void)setMaxLength:(int)_maxLength;
-(unsigned int)maxLength;
-(void)truncateToMaxLength;

/*actions*/
-(void)setTarget:(id)_target selector:(SEL)_selector;
-(SEL)selector;
-(id)target;
-(void)keyDown:(NSNotification *)theNotification;
-(NSString *)stringValue;

@end
