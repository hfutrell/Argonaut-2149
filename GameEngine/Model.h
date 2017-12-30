//
//  Model.h
//  NewtonTest
//
//  Created by Holmes Futrell on 5/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Common.h"
#import "Mesh.h"

typedef struct {
	GLuint textures[4];
	GLhandleARB shader;
	float diffuse, specular, shininess;
	int flat_shading;
} material;

typedef struct {
	int start_tri, end_tri;
	int start_quad, end_quad;
	material *mat;
} material_section;

@interface Model : Mesh {

	// models can subclass meshes (note how similar the variables are)
	// then they get stencil shadow functionality for free
	// the variables they add are an array of groups and materials
	// the groups just specify start / stop triangles and faces
	// as do the materials
	// when you draw you go set material draw material group in a loop
	// shadowing is as normal
	material_section *material_sections;
	int num_material_sections;
	
	GLuint list;
	
}

-(id)initWithResource:(NSString *)resource scale:(float)scale;
-(id)initWithFile:(NSString *)path scale:(float)scale;
-(void)buildList;
-(void)drawList;

@end