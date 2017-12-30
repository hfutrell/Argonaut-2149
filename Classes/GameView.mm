//
//  GameView.m
//  Argonaut
//
//  Created by Holmes Futrell on Mon Jun 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"
#import "Menu.h"
#import "Loading.h"

GameView *sharedInstance;
static float frameMultiply;

@interface GameView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame colorBits:(int)numColorBits;
- (BOOL) initGL;
@end

static Loading *loader;

@implementation GameView

+(id)SharedInstance {
    return sharedInstance;
}

-(void)setRenderScreen:(id)newScreen {

    renderScreen = newScreen;
    [self setNextResponder: renderScreen];
    
}

- (void)drawRect:(NSRect)rect {
          
    //glClearColor(1.0,0.0,0.0,1.0);
    glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
    glLoadIdentity();
            
    //[self viewPixel];
    [renderScreen make];
    
    //NSLog(@"Rect size x = %f size y = %f", [[NSScreen mainScreen] frame].size.width, [[NSScreen mainScreen] frame].size.height);
    
    [FocoaMod update3DSound];//WOAH, you only need to do this during the game, otherwise, sound = 1d
    [self flush];
        
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"MouseDown" object: theEvent];

}

-(void)mouseUp:(NSEvent *)theEvent {
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"MouseUp" object: theEvent];

} 

- (void) keyDown:(NSEvent *)theEvent {

    [[NSNotificationCenter defaultCenter]
postNotificationName:@"KeyDown" object: theEvent];
     
    if ([self nextResponder]) [[self nextResponder] keyDown: theEvent];
     
}

//-(void)pauseGame {

    //UNIMPLIMENTED

//}

-(void)transitionBetween:(id)from to:(id)to {

    [loader transitionBetween: from to: to];

}

- (BOOL)initGL {

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHT1);
    glEnable(GL_BLEND);
    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, 0.01);
    glEnable(GL_TEXTURE_2D);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_LINE_SMOOTH);  
    
    [FocoaMod initFMODWithMixRate: 44100 mixChannels: 32 flags: 0];
    [FocoaMod setDopplerFactor: 3.0]; //exagerate the doppler effect
    [FocoaMod setDistanceFactor: 3.0];
    
    //Some game stuff
    
    Menu *newMenu =  [Menu new];
    
    [self setRenderScreen: newMenu];
    loader = [Loading new];
    //NSLog(@"Done gameview init");
    return true;
}

- (void)flush {

    [[self openGLContext] flushBuffer];
    
}

- (void)viewPerspective
{
   glMatrixMode( GL_PROJECTION );   // Select Projection
   glPopMatrix();                   // Pop The Matrix
   glMatrixMode( GL_MODELVIEW );    // Select Modelview
   glPopMatrix();                   // Pop The Matrix
}

+(float)frameMultiply {
    return frameMultiply;
}

+(void)SetFrameMultiply:(float)newFrameMultiply {
    frameMultiply = newFrameMultiply;
}

- (void) reshape
{ 
    NSRect sceneBounds;
    sceneBounds = [ self bounds ];
    [ [ self openGLContext ] update ];
 
    glViewport( 0, 0, (int)sceneBounds.size.width, (int)sceneBounds.size.height );
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();   
    gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
                   0.1f, 100.0f );
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
}

/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame colorBits:(int)numColorBits;
{
    NSOpenGLPixelFormatAttribute attribsJaggy[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)numColorBits,
		NSOpenGLPFAStencilSize, (NSOpenGLPixelFormatAttribute)8,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        (NSOpenGLPixelFormatAttribute)NULL};
	
	int samples = [(NSNumber *)[[PreferenceController sharedInstance] prefForKey:@"samples"] intValue];
	BOOL samplesOn = samples != 0 ? YES : NO;
	
	NSOpenGLPixelFormatAttribute attribsSmooth[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)numColorBits,
		NSOpenGLPFAStencilSize, (NSOpenGLPixelFormatAttribute)8,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
		NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)samplesOn,
		NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)samples,
        (NSOpenGLPixelFormatAttribute)NULL};
	
    NSOpenGLPixelFormat *fmt;
    
    fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: attribsSmooth];
	if (!fmt) {
		fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: attribsJaggy];
	}
	
   return [fmt autorelease];
}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
       depthBits:(int)numDepthBits
{
   NSOpenGLPixelFormat *pixelFormat;

   colorBits = numColorBits;
   depthBits = numDepthBits;
   pixelFormat = [ self createPixelFormat:frame colorBits: numColorBits ];
   if( pixelFormat != nil )
   {
      self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
      [ pixelFormat release ];
      if( self )
      {
         sharedInstance = self;
         [ [ self openGLContext ] makeCurrentContext ];
         [ self reshape ];
         if( ![ self initGL ] )
         {
            [ self clearGLContext ];
            self = nil;
         }
      }
   }
   else
      self = nil;

   return self;
}

/*
 * Cleanup
 */
- (void) dealloc
{
    //NSLog(@"GL view quitting");
    //[FocoaMod freeAllSounds];
    [loader release];
    [renderScreen release];
    [super dealloc];
   
}

- (void) viewPixel {
    glMatrixMode( GL_PROJECTION );        // Select Projection
    //glPushMatrix();                       // Push The Matrix
    glLoadIdentity();                     // Reset The Matrix
    NSRect sceneBounds = [ self bounds ];
    //glOrtho( 0, sceneBounds.size.width, 0, sceneBounds.size.height, -1000, 1000 );
    //glOrtho( 0, 800, 600, 0, -1000, 1000 );
    glOrtho( 0, sceneBounds.size.width, sceneBounds.size.height, 0, -3000, 3000 );
    glMatrixMode( GL_MODELVIEW );         // Select Modelview Matrix
    //glPushMatrix();                       // Push The Matrix
    glLoadIdentity();                     // Reset The Matrix
}

- (void) view2D {
    glMatrixMode( GL_PROJECTION );        // Select Projection
                                          //glPushMatrix();                       // Push The Matrix
    glLoadIdentity();                     // Reset The Matrix
    glOrtho( 0, 800,600, 0, -1000, 1000 );
    glMatrixMode( GL_MODELVIEW );         // Select Modelview Matrix
                                          //glPushMatrix();                       // Push The Matrix
    glLoadIdentity();                     // Reset The Matrix
}

//- (void) view2DWithSize:(NSPoint)size {
//    glMatrixMode( GL_PROJECTION );        // Select Projection
//    //glPushMatrix();                       // Push The Matrix
//    glLoadIdentity();                     // Reset The Matrix
//    //glOrtho( 0, sceneBounds.size.width, 0, sceneBounds.size.height, -1000, 1000 );
//    glOrtho( 0, size.x, size.y, 0, -1000, 1000 );
//    glMatrixMode( GL_MODELVIEW );         // Select Modelview Matrix
    //glPushMatrix();                       // Push The Matrix
//    glLoadIdentity();                     // Reset The Matrix
//}

- (void) view3D
{ 
    NSRect sceneBounds = [ self bounds ];
    //[ [ self openGLContext ] update ];
    
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();   
    gluPerspective( 45.0f, [self bounds].size.width / [self bounds].size.height,
                   0.1f, 100.0f );
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
}

- (NSPoint) currentMousePosition
{
    NSPoint mouseLoc =   [[ self window ] convertScreenToBase:[ NSEvent mouseLocation ] ];
    mouseLoc.y = [ self bounds ].size.height - mouseLoc.y;
    return mouseLoc;
}


@end