//
//  GLFont.m
//  Argonaut
//
//  Created by Holmes Futrell on Tue Jul 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GLFont.h"


@implementation GLFont

-(id)initWithResource:(NSString *)resourceName xSpacing:(int)_xSpacing ySpacing:(int)_ySpacing {
    self = [super init];
	GLTexture *tex = [GLTexture initWithTGAResource:resourceName];
    [self buildFont: tex xSpacing:_xSpacing ySpacing:_ySpacing];
	[tex release];
    return self;
}

/*
 * Where the printing happens
 */
/*
- (void) printWithResource:(NSString *)resource inRect:(NSRect)rect {

    GLint x=0,y=0;

    char oneline[255];

    NSString *realName = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resource ];

    FILE *filein = fopen([realName fileSystemRepresentation], "rt");
    if (filein != NULL)
    {
        while (!feof(filein))
        {
            [self readLine:filein string: oneline];
            [self printAtX: x y: y string: oneline];
            y+=16;
        }
    }

} */

-(void)readLine:(FILE *)f string:(char *)string {
    fgets(string, 255, f);
}

-(int)xSpacing{
    return xSpacing;
}
-(int)ySpacing{
    return ySpacing;
}
-(int)charSpacing {
    return charSpacing;
}

- (void) printAtX:(GLint)x y:(GLint)y string:(const char *)string, ...
{

    //glPushAttrib(GL_LIGHTING);
    glDisable(GL_LIGHTING);
    
    char    text[ 256 ];   // Holds Our String
    va_list ap;            // Pointer To List Of Arguments

    if( string == NULL )   // If There's No Text
        return;             // Do Nothing

    va_start( ap, string );               // Parses The String For Variables
    vsnprintf( text, 256, string, ap );   // And Converts Symbols To Actual Numbers
    va_end( ap );                         // Results Are Stored In Text

    //Select Our Font Texture
    [fontTexture bind];
    glPushMatrix();                     // Store The Modelview Matrix
        glLoadIdentity();                   // Reset The Modelview Matrix
        glTranslated( x, y, 100 );            // Position The Text (0,0 - Bottom Left)
        glListBase( base - 32 );            // Choose The Font Set
        // Draws The Display List Text
        glCallLists( strlen( text ), GL_UNSIGNED_BYTE, text );
    glPopMatrix();                      // Restore The Old Projection Matrix
   
    glEnable(GL_LIGHTING);
    //glPopAttrib();
}

-(void)dealloc {
    
    [fontTexture release];
	glDeleteLists(base, 95);
    [super dealloc];

}

- (void)buildFont:(GLTexture *)newTexture xSpacing:(int)_xSpacing ySpacing:(int)_ySpacing
{

    fontTexture = [newTexture retain];
    
    int loop;
    
    xSpacing = _xSpacing;
    ySpacing = _ySpacing;

    base = glGenLists( 95 );   // Creating 95 Display Lists
    [fontTexture bind];   // Bind Our Font Texture
    for( loop = 0; loop < 95; loop++ )
    {
    
        int charPerX = [fontTexture imageWidth] / xSpacing;
        int charPerY = [fontTexture imageHeight] / ySpacing;
    
        float ix = 1.0 / (float)charPerX;
        float iy = 1.0 / (float)charPerY;
    
        float cx = (float) ( loop % charPerX ) / charPerX;
        float cy = (float) ( loop / charPerX ) / charPerY;
        
        charSpacing = xSpacing * (5.0/8.0);
        
        glNewList( base + loop, GL_COMPILE );   // Start Building A List
        
		glBegin( GL_QUADS );                    // Use A Quad For Each Character
      
            glTexCoord2f( cx, 1.0f - cy );
            glVertex2i( 0, 0 );              // Texture / Vertex Coord (Bottom Left)
            glTexCoord2f( cx + ix, 1.0f - cy );
            glVertex2i( xSpacing, 0 );             // Texutre / Vertex Coord (Bottom Right)
            glTexCoord2f( cx + ix, 1.0f - cy - iy);
            glVertex2i( xSpacing, ySpacing );            // Texture / Vertex Coord (Top Right)
            glTexCoord2f( cx, 1.0f - cy - iy );
            glVertex2i( 0, ySpacing );             // Texture / Vertex Coord (Top Left)
        glEnd();                    // Done Building Our Quad (Character)
        glTranslated( xSpacing * (5.0/8.0), 0, 0 );   // Move To The Right Of The Character
        
		glEndList();                // Done Building The Display List
   }
}

@end
