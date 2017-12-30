//
//  Particle.h
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"


@interface Particle : GameObject {

    GLTexture *sprite;
    float fade;
    float expansion;
    float size;
    float opacity;

    @public
        
        float radius;
    
}

+(id)sharedSet;
+(void)InitAssets;
+(void)deallocAssets;

+(GLTexture *)starburst;
+(GLTexture *)particle;
+(GLTexture *)shock;
+(GLTexture *)smoke;

+(void)makeAll;

+(void)spawnGroupAtPoint:(NSPoint)position
                advance:(float)advance
                number:(int)number
                speed:(float)speed
                expansion:(float)expansion
                fade:(float)fade
                size:(float)_size
                sprite:(GLTexture *)_sprite;
                
+(id)spawnAtPoint:(NSPoint)position
        rotation:(float)rotation
        speed:(float)speed
        expansion:(float)_expansion
        fade:(float)_fade
        size:(float)_size
        sprite:(GLTexture *)_sprite;

-(void)make;
-(void)drawQuadOfSize:(float)scale;

@end
