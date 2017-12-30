//
//  Mesh.h
//  NewtonTest
//
//  Created by Holmes Futrell on 4/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

#import "Common.h"

@interface Mesh : NSObject {

	vec2 *tex_coords;

	vec3 *vertices;
	vec3 *normals;
	vec3 *face_normals;
	triangle *triangles;
	quad *quads;
	
	edge *edges;
	
	BOOL flat_shading;
	BOOL use_tangent_space;

	int num_vertices, num_normals, num_triangles, num_quads, num_edges, num_tex_coords;

}

- (void)draw;
- (void)drawOutline:(vec4)light;
- (id)initWithTriangles:(int)_num_triangles quads:(int)_num_quads vertices:(int)_num_vertices normals:(int)_num_normals;
- (void)drawOutline:(vec4)light;
- (void)assembleEdges;
- (void)generateFaceNormals;
//- (void)generateTangentSpaces;

@end
