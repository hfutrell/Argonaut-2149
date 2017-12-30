//
//  Particle.m
//  Argonaut
//
//  Created by Holmes Futrell on Sun Jul 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"

static GLTexture *starburst,*particle,*shock,*smoke;
static NSMutableSet *sharedSet;

static GLTexture *previouslyUsedSprite;

@interface Particle (InternalMethods)
    -(void)drawQuadOfSize:(float)size;
@end

@implementation Particle

+(id)sharedSet {
    return !sharedSet ? sharedSet = [NSMutableSet new] : sharedSet;
}

+(void)InitAssets{

    starburst = [GLTexture initWithTGAResource:@"data/sprites/starburst.tga"];
    particle = [GLTexture initWithTGAResource:@"data/sprites/particle.tga"];
    shock = [GLTexture initWithTGAResource:@"data/sprites/shockwave.tga"];
    smoke = [GLTexture initWithTGAResource:@"data/sprites/smoke.tga"];

}

+(void)deallocAssets {

    [starburst release];
    [particle release];
    [shock release];
    [smoke release];
    [sharedSet removeAllObjects];
    [sharedSet release];
    sharedSet = nil;
    
}

+(GLTexture *)starburst {
    return starburst;
}
+(GLTexture *)particle {
    return particle;
}
+(GLTexture *)shock {
    return shock;
}
+(GLTexture *)smoke {
    return smoke;
}

+(void)makeAll {

    glPushAttrib(GL_LIGHTING);

    glDisable(GL_LIGHTING);
    glPushMatrix();

	NSArray *a = [[Particle sharedSet] allObjects];

	int i;
	for (i=0; i<[a count]; i++) {
		Particle *cur = (Particle *)[a objectAtIndex: i];
		[cur make];
	}
    
    glPopMatrix();
    glPopAttrib();
	
	previouslyUsedSprite = nil;


}

+(void)spawnGroupAtPoint:(NSPoint)position
                advance:(float)advance
                number:(int)number
                speed:(float)_speed
                expansion:(float)_expansion
                fade:(float)_fade
                size:(float)_size
                sprite:(GLTexture *)_sprite {
                
          
    if (![GameObject pointOnScreen: position]) return;
                            
    int i;
    for (i=0;i<number;i++){
    
        NSPoint point;
        float rotation = [Randomness randomFloat: 0 max: 360];
        
        point.x = position.x + degreeCosine(rotation)*advance;
        point.y = position.y + degreeSine(rotation)*advance;
    
        [Particle spawnAtPoint:point
            rotation:rotation
            speed: [Randomness randomFloat: 0 max : _speed]/2.0 + _speed/2.0
            expansion:_expansion
            fade:_fade
            size:_size
            sprite:_sprite];
    }
}
    
+(id)spawnAtPoint:(NSPoint)position
        rotation:(float)rotation
        speed:(float)speed
        expansion:(float)_expansion
        fade:(float)_fade
        size:(float)_size
        sprite:(GLTexture *)_sprite {
        
        
        Particle *newParticle = [Particle new];
        newParticle->pos[0]=position.x;
        newParticle->pos[1]=position.y;
        newParticle->vel[0]= speed * degreeCosine(rotation);
        newParticle->vel[1]= speed * degreeSine(rotation);
        newParticle->rot = rotation;
        newParticle->size = _size;
        newParticle->sprite = _sprite;
        newParticle->fade = _fade;
        newParticle->expansion = _expansion;
        newParticle->opacity = 1.0;
        newParticle->radius = sqrt(2*pow(_size,2));
		
		float maxRot = 150.0f/_size;
		
		newParticle->rotvel = [Randomness randomFloat: 0 max: maxRot]-(maxRot/2.0f);
        
        if ([newParticle isOnScreen]) {
            [[Particle sharedSet] addObject: newParticle];
			[newParticle release];
			return newParticle;
        }
        else {
            [newParticle release];
            return nil;
        
        }
}

-(void)make {

    pos[0] += vel[0] * FRAME;
    pos[1] += vel[1] * FRAME;
    pos[2] += vel[2] * FRAME;
	
	vel[0] *= (1.0 - 0.03 * FRAME);
	vel[1] *= (1.0 - 0.03 * FRAME);

	rot += rotvel * FRAME;
    size += expansion * FRAME;
    opacity += fade * FRAME;
        
    glPushMatrix();
    
        glTranslatef(pos[0],pos[1],pos[2]);
        glRotatef(rot,0,0,1);
		
        //if (sprite != previouslyUsedSprite){
		[sprite bind];
			//cache the texture used in order to not have to bind the texture each frame.
		//	previouslyUsedSprite = sprite;
		//}
		
        glColor4f(1.0,1.0,1.0,opacity);
        [self drawQuadOfSize: size];
    
    glPopMatrix();
    
    if (opacity <= 0) { //if it's completely faded, remove it
        [[Particle sharedSet] removeObject: self];
        return;
    }
        
}

-(void)drawQuadOfSize:(float)scale {
        
    glBegin(GL_QUADS);
        
        glTexCoord2f(0.0,1.0);
        glVertex2f(-scale/2.0,-scale/2.0);
        glTexCoord2f(1.0,1.0);
        glVertex2f(scale/2.0,-scale/2.0);
        glTexCoord2f(1.0,0.0);
        glVertex2f(scale/2.0,scale/2.0);
        glTexCoord2f(0.0,0.0);
        glVertex2f(-scale/2.0,scale/2.0);
    
    glEnd();
    
}

@end
