//
//  Mesh.m
//  NewtonTest
//
//  Created by Holmes Futrell on 4/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Mesh.h"

@implementation Mesh

- (id)initWithTriangles:(int)_num_triangles quads:(int)_num_quads vertices:(int)_num_vertices normals:(int)_num_normals {

	self = [super init];

	num_triangles = _num_triangles;
	num_vertices = _num_vertices;
	num_normals = _num_normals;
	num_quads = _num_quads;
	
	if(num_triangles > 0) triangles = (triangle *)malloc( num_triangles * sizeof(triangle));
	if(num_quads > 0) quads = (quad *)malloc( num_quads * sizeof(quad));
	vertices = (vec3 *)malloc( num_vertices * sizeof(vec3));
	if (num_normals > 0) normals = (vec3 *)malloc( num_normals * sizeof(vec3));
	face_normals = (vec3 *)malloc( (num_quads + num_triangles) * sizeof(vec3));

	NSLog(@"allocated %d spaces for face normals", num_quads + num_triangles);

	flat_shading = YES;

	return self;

}

- (void)generateFaceNormals {

	if (!face_normals) face_normals = (vec3 *)malloc( (num_quads + num_triangles) * sizeof(vec3));

	int i;
	for (i=0; i<num_triangles; i++) {
		vec3 c1 = difference(vertices[triangles[i].v2], vertices[triangles[i].v1]);
		vec3 c2 = difference(vertices[triangles[i].v3], vertices[triangles[i].v1]);
		int normal_index = i;
		face_normals[normal_index] = normalize(cross(c1, c2));
		triangles[i].fsn = normal_index;
	}
	
	for (i=0; i<num_quads; i++) {
		vec3 c1 = difference(vertices[quads[i].v2], vertices[quads[i].v1]);
		vec3 c2 = difference(vertices[quads[i].v4], vertices[quads[i].v1]);
		int normal_index = i + num_triangles;
		face_normals[normal_index] = normalize(cross(c1, c2));
		quads[i].fsn = normal_index;
	}

}

/*-(void)generateTangentSpaces {

	int i;
	for (i=0; i<num_quads; i++) {
	
		quad q = quads[i];
	
		//vec3 v1 = normalize(difference(vertices[q.v2], vertices[q.v1]));
		//vec3 v2 = face_normals[q.fsn];
		//vec3 v3 = scalar_multiply(-1.0f, cross(v1, v2));
		
		//build_mat3(q.tangent, v1, v2, v3);
		//transpose_mat3(q.tangent);

	}
	
	for (i=0; i<num_triangles; i++) {
	
		triangle t = triangles[i];
	
		vec3 v1 = normalize(difference(vertices[t.v2], vertices[t.v1]));
		vec3 v2 = face_normals[t.fsn];
		vec3 v3 = scalar_multiply(-1.0f, cross(v1, v2));
		
		//build_mat3(t.tangent, v1, v2, v3);
		//transpose_mat3(t.tangent);
		
	}

	use_tangent_space = YES;
	
}*/


edge construct_edge(int v1, int v2, int t1, int t2, int face_type1, int face_type2) {
	edge e;
	e.v1 = v1;
	e.v2 = v2;
	e.t1 = t1;
	e.t2 = t2;
	e.face_type1 = face_type1;
	e.face_type2 = face_type2;
	return e;
}

- (void)assembleEdges {

	int i, j;
	
	int curr = 0;
	
	int length = 3 * num_triangles + 4 * num_quads;
	edge *list = (edge *)malloc(length * sizeof(edge));
	
	for (i=0; i<num_triangles; i++) {
		list[curr++] = construct_edge( triangles[i].v1, triangles[i].v2, i, -1, TRIANGLE, -1);
		list[curr++] = construct_edge( triangles[i].v2, triangles[i].v3, i, -1, TRIANGLE, -1);
		list[curr++] = construct_edge( triangles[i].v3, triangles[i].v1, i, -1, TRIANGLE, -1);
	}
	for (i=0; i<num_quads; i++) {
		list[curr++] = construct_edge( quads[i].v1, quads[i].v2, i, -1, QUAD, -1);
		list[curr++] = construct_edge( quads[i].v2, quads[i].v3, i, -1, QUAD, -1);
		list[curr++] = construct_edge( quads[i].v3, quads[i].v4, i, -1, QUAD, -1);
		list[curr++] = construct_edge( quads[i].v4, quads[i].v1, i, -1, QUAD, -1);
	}
	
	for (i=0; i<length; i++) {
		for (j=0; j<i; j++) {
			
			if (list[j].face_type1 == NONE) continue;
		
			/* are we the reverse edge of something ealier in the list? */
			
			if(equal_vec3(vertices[list[i].v1], vertices[list[j].v2]) && equal_vec3(vertices[list[i].v2], vertices[list[j].v1])) {
			
			//if (list[i].v1 == list[j].v2 && list[i].v2 == list[j].v1) {
				
				// fill in this edge second face attributes
				list[j].face_type2 = list[i].face_type1;
				list[j].t2 = list[i].t1;
				
				list[i].face_type1 = NONE; /* invalidate this face */

				
			}
		}
	}

	num_edges = 0;
	for (i=0; i<length; i++)
		if (list[i].face_type1 != NONE)
			num_edges++;

	edges = (edge *)malloc(num_edges * sizeof(edge));
	
	curr = 0;
	for (i=0; i<length; i++) {
		if (list[i].face_type1 != NONE) {
			edges[curr++] = list[i];
		}
	}
	
	free(list);
	

}

- (void)draw {
	

	int i;

	glBegin(GL_TRIANGLES);
		
	for (i=0; i<num_triangles; i++) {
	
		if (flat_shading)	glNormal3fv(face_normals[triangles[i].fsn].coords);
		else				glNormal3fv(normals[triangles[i].n1].coords);
		glVertex3fv(vertices[triangles[i].v1].coords);
		
		if (flat_shading)	glNormal3fv(face_normals[triangles[i].fsn].coords);
		else				glNormal3fv(normals[triangles[i].n2].coords);
		glVertex3fv(vertices[triangles[i].v2].coords);

		if (flat_shading)	glNormal3fv(face_normals[triangles[i].fsn].coords);
		else				glNormal3fv(normals[triangles[i].n3].coords);
		glVertex3fv(vertices[triangles[i].v3].coords);
	}
	
	glEnd();

	glBegin(GL_QUADS);
	for (i=0; i<num_quads; i++) {
	
		if (flat_shading)	glNormal3fv(face_normals[quads[i].fsn].coords);
		else				glNormal3fv(normals[quads[i].n1].coords);
		glVertex3fv(vertices[quads[i].v1].coords);
		
		if (flat_shading)	glNormal3fv(face_normals[quads[i].fsn].coords);
		else				glNormal3fv(normals[quads[i].n2].coords);
		glVertex3fv(vertices[quads[i].v2].coords);

		if (flat_shading)	glNormal3fv(face_normals[quads[i].fsn].coords);
		else				glNormal3fv(normals[quads[i].n3].coords);
		glVertex3fv(vertices[quads[i].v3].coords);

		if (flat_shading)	glNormal3fv(face_normals[quads[i].fsn].coords);
		else				glNormal3fv(normals[quads[i].n4].coords);
		glVertex3fv(vertices[quads[i].v4].coords);
	}
	glEnd();	

}

-(void)dealloc {
	free(triangles);
	free(vertices);
	free(normals);
	free(edges);
	free(quads);
	free(face_normals);
	[super dealloc];
}


vec3 projectVectorFromLight(vec3 v1, vec4 light) {

	vec3 result;
	float t = 100.0f;
	result.coords[0] = v1.coords[0] * 1.0f  - light.coords[0] * t;
	result.coords[1] = v1.coords[1] * 1.0f  - light.coords[1] * t;
	result.coords[2] = v1.coords[2] * 1.0f  - light.coords[2] * t;
	return result;
}

- (void)drawOutline:(vec4)light {

	edge stack[num_edges];
	int curr = 0;
	
	int i;
	for (i=0; i<num_edges; i++) {
		
		vec4 n1, n2;
		if (edges[i].face_type1 == TRIANGLE) n1 = point_to_vector(face_normals[triangles[edges[i].t1].fsn]);
		else if (edges[i].face_type1 == QUAD) n1 = point_to_vector(face_normals[quads[edges[i].t1].fsn]);
		
		if (edges[i].face_type2 == TRIANGLE) n2 = point_to_vector(face_normals[triangles[edges[i].t2].fsn]);
		else if (edges[i].face_type2 == QUAD) n2 = point_to_vector(face_normals[quads[edges[i].t2].fsn]);
		
		float dot1 = dot_vec4(n1, light); 
		float dot2 = dot_vec4(n2, light);
				
		if ( dot1 * dot2 <= 0.0f) {
			edges[i].dir = dot1 > 0;
			stack[curr++] = edges[i];
		}
		
	}

	glColor4f(1.0,0.0,0.0,1.0);
	glBegin(GL_QUADS);
	glLineWidth(10);
	for (i=0; i<curr; i++) {
		
		vec3 v1 = vertices[stack[i].v1];
		vec3 v2 = vertices[stack[i].v2];
		vec3 ex1 = projectVectorFromLight( v1, light ); 
		vec3 ex2 = projectVectorFromLight( v2, light ); 
		
		if (stack[i].dir == 0) {
			glVertex3fv( v1.coords );
			glVertex3fv( v2.coords );
			glVertex3fv( ex2.coords );
			glVertex3fv( ex1.coords );
		}
		else {
			glVertex3fv( ex1.coords );
			glVertex3fv( ex2.coords );
			glVertex3fv( v2.coords );
			glVertex3fv( v1.coords );
		}
		
	}
	glEnd();

}

@end
