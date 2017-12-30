//
//  GLTexture.m
//  Aquarium
//
//  Created by Holmes Futrell on Fri Apr 04 2003.
//  Copyright (c) 2003 Constant Variable. All rights reserved.
//

#import "GLTexture.h"

static BOOL shouldMipMap=TRUE;

@implementation GLTexture

+(void)enableMipMapping{
    shouldMipMap=TRUE;
}
+(void)disableMipMapping{
    shouldMipMap=FALSE;
}
+(BOOL)isMipMapping{
    return shouldMipMap ;
}
+(void)setMipMapping:(BOOL)_state {
    shouldMipMap=_state;
}

+(id)initWithFile:(NSString *)filename{
    GLTexture *newTextureObject = [[GLTexture alloc] init];
    [newTextureObject loadNSImage: filename];
    
    return newTextureObject;
}

-(id)emptyTextureWithSize:(NSSize)size {
   // calloc() will zero out the memory for us
   //*4 is for RGBA
   
    texSize = size;
   
    texBytes = calloc( (int)texSize.width * (int)texSize.height * 4, sizeof( GLuint ) );


    glGenTextures( 1, &texture );   // Create one texture
    glBindTexture( GL_TEXTURE_2D, texture );
    glTexImage2D( GL_TEXTURE_2D, 0, 4, (int)texSize.width, (int)texSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                 texBytes );   // Build texture using empty buffer
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

    //free( texBytes );

   return self;
}

- (id)renderToTextureWithView:(id)view
    selector:(SEL)selector
    target:(id)target
{

    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

   glViewport( 0, 0, [self imageWidth], [self imageHeight] );   // Set Our Viewport (Match Texture Size)

    [target performSelector: selector ];

    [self bind];

   // Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
    [self grabScreenBuffer];

    //clean up after ourselves
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    //revert the viewport to its original size
    glViewport( 0, 0, [view bounds].size.width, [view bounds].size.height );
    return self;
}

-(id)grabScreenBuffer {

    //no alpha
    glCopyTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, 0, [self imageWidth], [self imageHeight], 0 );
    return self;

}


+(id)initWithResource:(NSString *)resourceName{
    GLTexture *newTextureObject = [[GLTexture alloc] init];
    NSString *realName = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resourceName ];
   
    if (![[NSFileManager defaultManager] fileExistsAtPath: realName ]){
        NSLog(@"GLTexture Generic can't find %@",realName);
        return nil;
    } 
    
    [newTextureObject loadNSImage: realName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Item Loaded" object: newTextureObject];

    return newTextureObject;
}

+(id)initWithTGAResource:(NSString *)resourceName{
    GLTexture *newTextureObject = [[GLTexture alloc] init];
    NSString *realName = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resourceName ];
   
    if (![[NSFileManager defaultManager] fileExistsAtPath: realName ]){
        NSLog(@"GLTexture TGA can't find %@",realName);
        return nil;
    } 
    
    [newTextureObject loadTGA: realName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Item Loaded" object: newTextureObject];
    
    return newTextureObject;
}

+(id)initWithTGA:(NSURL *)filename {
    GLTexture *newTextureObject = [[GLTexture alloc] init];
    [newTextureObject loadTGA: [filename path]];
    return newTextureObject;
}

+(id)initWithOpenPanel {

    NSOpenPanel *op;
    op = [NSOpenPanel openPanel];
    [op runModalForTypes: [NSArray arrayWithObjects:@"jpg",@"JPG",@"BMP",@"bmp",nil]];
    
    if ([op filename]) {
    
        GLTexture *newTextureObject = [[GLTexture alloc] init];
        [newTextureObject loadNSImage: [op filename]];
        return newTextureObject;
    
    }
    
    return nil;

}

//allows other classes direct access to texture data
//-(char *)texBytes{

//    return texBytes;

//}

-(void)dealloc {

    glDeleteTextures(1, &texture);
	free(texBytes);
    [super dealloc];

}

-(int)alphaAtPoint:(NSPoint)point {

    if (point.x < [self imageWidth] && point.x >= 0 && point.y < [self imageHeight] && point.y >= 0 && texFormat == GL_RGBA){
   
        int memoryLocation = 3+4*(int)(point.x + (point.y * [self imageWidth]));
        //make sure it it can by no means access from a subscript not in the array
        if ( memoryLocation < ([self imageWidth]-1)*([self imageHeight]-1)*4) {
            return (int)texBytes[ memoryLocation ];
        }
    }
    return FALSE;
}

//-(void)setStartVertex:(int)newStart {
//    startVertex = newStart;
//}

//-(void)setEndVertex:(int)newEnd {
//    endVertex = newEnd;
//}

// the obsolete version
//+(id)initWithTGA:(NSString *)filename{
//    GLTexture *newTextureObject = [[super alloc] init];
//    [newTextureObject loadTGA: filename];
//    return newTextureObject;
//}

-(BOOL)loadNSImage:(NSString *)filename
{
    NSBitmapImageRep *theImage;
    int bitsPPixel, bytesPRow;
    unsigned char *theImageData;
    int rowNum, destRowNum;
    BOOL success;
    
    //imageRep = [[NSImage alloc] initWithContentsOfFile: filename];
    
    //NSString *realName;
    //realName = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], filename ];
    
    theImage = [ NSBitmapImageRep imageRepWithContentsOfFile:filename ];
    if( theImage != nil )
    {
        bitsPPixel = [ theImage bitsPerPixel ];
        bytesPRow = [ theImage bytesPerRow ];
        if( bitsPPixel == 24 ){        // No alpha channel
            //NSLog(@"No Alpha Channel");
            texFormat = GL_RGB;
        }
        else if( bitsPPixel == 32 ){   // There is an alpha channel
            //NSLog(@"Alpha channel detected");
            texFormat = GL_RGBA;
        }
        //else {
        //    NSRunCriticalAlertPanel( @"Error", @"Inavlid image, check that its RGB.", nil, nil, nil );
        //    printf("Failed, can't find bit data.\n");
        //    return FALSE;
        //}
        texSize.width = [ theImage pixelsWide ];
        texSize.height = [ theImage pixelsHigh ];
        texBytes = calloc( bytesPRow * texSize.height,
                                     1 );
        if( texBytes != NULL )
        {
            success = TRUE;
            theImageData = [ theImage bitmapData ];
            destRowNum = 0;
            for( rowNum = texSize.height - 1; rowNum >= 0;
                rowNum--, destRowNum++ )
            {
            // Copy the entire row in one shot
            memcpy( texBytes + ( destRowNum * bytesPRow ),
                    theImageData + ( rowNum * bytesPRow ),
                    bytesPRow );
            }
        }
        else {
            printf("Loading image %s failed", [filename fileSystemRepresentation]);
            return FALSE;
        }
    }
    
    glGenTextures( 1, &texture );
    glBindTexture( GL_TEXTURE_2D, texture );

    if ([GLTexture isMipMapping]){


        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
            GL_LINEAR_MIPMAP_NEAREST );
        gluBuild2DMipmaps( GL_TEXTURE_2D, 4, texSize.width,
            texSize.height, texFormat,
            GL_UNSIGNED_BYTE, texBytes );
        //free( texBytes );
    
    }
    else {
                                                   // Linear filtered
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexImage2D( GL_TEXTURE_2D, 0, texFormat, texSize.width, texSize.height,
                      0, texFormat, GL_UNSIGNED_BYTE, texBytes );       
    
    }
    //printf("Success.\n");
    return TRUE;
}

-(void)bind {
    //glActiveTextureARB(33984);
    glBindTexture(GL_TEXTURE_2D, texture);
}

/* -(void)failure:(NSString *)message {
    NSWindow *infoWindow = NSGetCriticalAlertPanel( @"Texture.m Warning!",
                                        message,
                                        @"OK", nil, nil );
    [ NSApp runModalForWindow:infoWindow ];
    [ infoWindow close ];
} */

//MultiTexturing Support 

//this function detects whether or not
//multitexturing is enabled.  If it is,
//it returns the number of texture units,
//if not, it returns 0.
+(BOOL)multiTextureEnabled {

    
#ifdef __ARB_ENABLE
    
    unsigned const char *extensions; //not actually using this
    
    if( gluCheckExtension( "GL_ARB_multitexture", extensions ) &&
        __ARB_ENABLE && gluCheckExtension( "GL_ARB_texture_env_combine",
                                          extensions ) )
    {
        GLint maxTexelUnits;
        glGetIntegerv( GL_MAX_TEXTURE_UNITS_ARB, &maxTexelUnits );
        NSLog(@"Multitexturing supported.  You've got %d texture units", maxTexelUnits);
        return TRUE;
    }
    
#endif
    
    return FALSE;
}

+(int)multiTextureUnits {
        
    GLint maxTexelUnits;
    glGetIntegerv( GL_MAX_TEXTURE_UNITS_ARB, &maxTexelUnits );
    return maxTexelUnits;
    
}

+(void)setSphereMapping:(BOOL)newState {

    if (newState) {
    
        glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
    
    }
    else {
    
        glDisable(GL_TEXTURE_GEN_S);
        glDisable(GL_TEXTURE_GEN_T);
    
    }

}

+(void)setActiveTextureARB:(int)unit {
    
    glActiveTextureARB(33984+unit); //33985 = GL_TEXTURE1_ARB
    
}

-(void)bindToTexelUnit:(int)unit {

    if (unit > [GLTexture multiTextureUnits] ) {
        NSLog(@"Warning, Graphics card doesn't have %d texel units.",unit);
    }
    
    glActiveTextureARB(33984+unit); //33985 = GL_TEXTURE1_ARB
    glBindTexture(GL_TEXTURE_2D, texture);

}

//-(NSImage *)image {

//    return imageRep;

//}

-(unsigned int)imageWidth {
    return texSize.width;
}

-(unsigned int)imageHeight {
    return texSize.height;
}

- (BOOL) loadTGA:(NSString *)filename {
 
    return [self loadTGA: filename nearFilter: GL_LINEAR farFilter: GL_LINEAR mipMapping: NO ];
    
}

- (BOOL) loadTGA:(NSString *)filename nearFilter:(GLenum)nearFilter farFilter:(GLenum)farFilter mipMapping:(BOOL)mipMapping {
   
    //warning MIPMAPPING NOT ENABLED IN CODE
    
    //imageRep = [[NSImage alloc] initWithContentsOfFile: filename];
    
   // Uncompressed TGA Header
   GLubyte TGAheader[ 12 ] = { 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
   GLubyte TGAcompare[ 12 ];   // Used To Compare TGA Header
   GLubyte header[ 6 ];        // First 6 Useful Bytes From The Header
   GLuint  bytesPerPixel;      // No. Of Bytes Per Pixel Used In The TGA File
   GLuint  imageSize;          // Store Image Size When Setting Aside Ram
   GLuint  temp;               // Temporary Variable
    texFormat = GL_RGBA;   // Set The Default GL Mode To RBGA (32 BPP)
   GLuint  i;
   FILE    *file = fopen( [ filename fileSystemRepresentation ], "rb" );

   /*
    * If file couldn't be opened, or doesn't have the right data (12 bytes
    * first, which we like, then another 6 for the header), then we return
    * FALSE
    */
   if( file == NULL ||
       fread( TGAcompare, 1, sizeof( TGAcompare ), file ) !=
          sizeof( TGAcompare ) ||
       memcmp( TGAheader, TGAcompare, sizeof( TGAheader ) ) != 0 ||
       fread( header, 1, sizeof( header ), file ) != sizeof( header ) )
   {
      if( file != NULL )
         fclose( file );
        printf("Loading TGA %s failed.\n", [filename fileSystemRepresentation]);

      return FALSE;
   }

   // Determine The TGA Width      (highbyte*256+lowbyte)
   texSize.width  = header[ 1 ] * 256 + header[ 0 ];
   // Determine The TGA Height     (highbyte*256+lowbyte)
   texSize.height = header[ 3 ] * 256 + header[ 2 ];

   /*
    * If the width or height is invalid, or isn't 24 or 32 bit, we take off
    */
   if( texSize.width  <= 0 ||
       texSize.height <= 0 ||
       ( header[ 4 ] != 24 && header[ 4 ] != 32 ) )
   {
      fclose( file );
       printf("Loading TGA %s failed.\n", [filename fileSystemRepresentation]);
      return FALSE;
   }

   int bpp    = header[ 4 ];  // Grab The TGA's Bits Per Pixel (24 or 32)
    bytesPerPixel   = bpp / 8;   // Divide By 8 To Get The Bytes Per Pixel
   // Calculate The Memory Required For The TGA Data
   imageSize = texSize.width * texSize.height * bytesPerPixel;

   // Reserve Memory To Hold The TGA Data
   texBytes = (GLubyte *)malloc( imageSize );

   /*
    * If we can create the memory, or don't read in enough data, we leave
    */
   if( texBytes == NULL ||
       fread( texBytes, 1, imageSize, file ) != imageSize )
   {
      if( texBytes != NULL )   // Was Image Data Loaded
         free( texBytes );     // If So, Release The Image Data

        printf("Loading TGA %s failed\n", [filename fileSystemRepresentation]);
      fclose( file );   // Close The File
      return FALSE;
   }

   /*
    * Loop through the image data; swaps the first and third bytes (red and blue)
    */
   for( i = 0; i < (int) imageSize; i += bytesPerPixel )
   {
      // Temporarily Store The Value At Image Data 'i'
      temp=texBytes[ i ];
      // Set The 1st Byte To The Value Of The 3rd Byte
      texBytes[ i ] = texBytes[ i + 2 ];
      // Set The 3rd Byte To The Value In 'temp' (1st Byte Value)
     texBytes[ i + 2 ] = temp;
   }

   fclose( file );   // Close The File

   // Build A Texture From The Data
     glGenTextures( 1, &texture );   // Generate OpenGL texture IDs

   glBindTexture( GL_TEXTURE_2D, texture );   // Bind Our Texture
   // Linear filtered
   glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, nearFilter );
   glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, farFilter );

   if( bpp == 24 )   // Was The TGA 24 Bits
      texFormat = GL_RGB;              // If So Set The 'type' To GL_RGB

   glTexImage2D( GL_TEXTURE_2D, 0, texFormat, texSize.width, texSize.height,
                 0, texFormat, GL_UNSIGNED_BYTE, texBytes );

   return TRUE;
}

-(NSString *)description {
 
    return [NSString stringWithFormat:@"GLTexture object, width = %d, height = %d",[self imageWidth],[self imageHeight]];
    
}

-(NSSize)size {

	return texSize;

}

@end
