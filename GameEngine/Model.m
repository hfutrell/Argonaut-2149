//
//  Model.m
//  NewtonTest
//
//  Created by Holmes Futrell on 5/19/07.
//  Copyright 2007 Holmes Futrell. All rights reserved.
//

#import "Model.h"
#import "Common.h"

#define MAX_VERTICES 100000
#define MAX_NORMALS MAX_VERTICES
#define MAX_TEX_COORDS MAX_VERTICES
#define MAX_TRIANGLES 30000
#define MAX_QUADS 30000
#define MAX_MATERIAL_SECTIONS 200

@implementation Model

-(id)initWithResource:(NSString *)resource scale:(float)scale {
    NSString *path = [ NSString stringWithFormat:@"%@/%@", [ [ NSBundle mainBundle ] resourcePath ], resource ];
	return [self initWithFile: path scale: scale ];
}

-(id)initWithFile:(NSString *)path scale:(float)scale {

	self = [super init];
	
	num_vertices = num_tex_coords = num_normals = num_triangles = num_quads = num_material_sections = 0;
	
	vec3 *temp_vertices							= (vec3 *)malloc(sizeof(vec3) * MAX_VERTICES);
	vec3 *temp_normals							= (vec3 *)malloc(sizeof(vec3) * MAX_NORMALS);
	vec2 *temp_tex_coords						= (vec2 *)malloc(sizeof(vec2) * MAX_TEX_COORDS);
	triangle *temp_triangles					= (triangle *)malloc(sizeof(triangle) * MAX_TRIANGLES);
	quad *temp_quads							= (quad *)malloc(sizeof(quad) * MAX_QUADS);
	material_section *temp_material_sections	= (material_section *)malloc(sizeof(material_section) * MAX_MATERIAL_SECTIONS);

	FILE *f = fopen([path UTF8String], "rt");
	
	if (f == NULL) {
		NSLog(@"Couldn't open model %@!", path);
		return NULL;
	}
	
	char line[1024];
		
	while(fgets(line, 1024, f) != NULL) {
	
		vec3 tempv3;
		vec2 tempv2;
		triangle tempt;
		quad tempq;
		char temps[128];
		
		if (sscanf(line, "v %f %f %f", &tempv3.coords[0], &tempv3.coords[1], &tempv3.coords[2]) == 3) {
			temp_vertices[num_vertices++] = make_vec3(scale * tempv3.coords[0], scale * tempv3.coords[1], scale * tempv3.coords[2]);
		}
		else if (sscanf(line, "vt %f %f", &tempv2.coords[0], &tempv2.coords[1]) == 2) {
			temp_tex_coords[num_tex_coords++] = tempv2;
		}
		else if (sscanf(line, "vn %f %f %f", &tempv3.coords[0], &tempv3.coords[1], &tempv3.coords[2]) == 3) {
			temp_normals[num_normals++] = normalize(tempv3);
		} // quads
		else if (sscanf(line, "f %d %d %d %d", &tempq.v1, &tempq.v2, &tempq.v3, &tempq.v4) == 4) {
			temp_quads[num_quads] = tempq;
			num_quads++;
		}
		else if (sscanf(line, "f %d/%d %d/%d %d/%d %d/%d", \
			&tempq.v1, &tempq.t1, &tempq.v2, &tempq.t2, &tempq.v3, &tempq.t3, &tempq.v4, &tempq.t4) == 8) {
			temp_quads[num_quads] = tempq;
			num_quads++;
		}
		else if (sscanf(line, "f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d", \
			&tempq.v1, &tempq.t1, &tempq.n1, &tempq.v2, &tempq.t2, &tempq.n2, &tempq.v3, &tempq.t3, &tempq.n3, &tempq.v4, &tempq.t4, &tempq.n4) == 12) {
			temp_quads[num_quads] = tempq;
			num_quads++;
		} // triangles
		else if (sscanf(line, "f %d %d %d", &tempt.v1, &tempt.v2, &tempt.v3) == 3) {
			temp_triangles[num_triangles] = tempt;
			num_triangles++;
		}
		else if (sscanf(line, "f %d/%d %d/%d %d/%d", &(tempt.v1), &(tempt.t1), &(tempt.v2), &(tempt.t2), &(tempt.v3), &(tempt.t3)) == 6) {
			temp_triangles[num_triangles] = tempt;
			num_triangles++;
		}
		else if (sscanf(line, "f %d/%d/%d %d/%d/%d %d/%d/%d", \
			&tempt.v1, &tempt.t1, &tempt.n1, &tempt.v2, &tempt.t2, &tempt.n2, &tempt.v3, &tempt.t3, &tempt.n3) == 9) {
			temp_triangles[num_triangles] = tempt;
			num_triangles++;
		}
		else if (sscanf(line, "usemtl %s", temps) == 1) {
			temp_material_sections[num_material_sections].start_tri = num_triangles;
			temp_material_sections[num_material_sections].start_quad = num_quads;
			if (num_material_sections != 0) {
				temp_material_sections[num_material_sections-1].end_tri = num_triangles;
				temp_material_sections[num_material_sections-1].end_quad = num_quads;
			}
			num_material_sections++;
		}
		else if (line[0] == '#' || line[0] == '\n') {
			continue;
		}
		else {
			//printf("I don't know what to do with %s", line);
		}

	}
	
	// close off the final material section
	temp_material_sections[num_material_sections-1].end_tri = num_triangles;
	temp_material_sections[num_material_sections-1].end_quad = num_quads;

	/*
		the .obj file starts with index 1 instead of 0 so we add padding
	*/
	vertices = (vec3 *)malloc(sizeof(vec3) * (num_vertices+1));
	tex_coords = (vec2 *)malloc(sizeof(vec2) * (num_tex_coords+1));
	normals = (vec3 *)malloc(sizeof(vec3) * (num_normals+1));
	triangles = (triangle *)malloc(sizeof(triangle) * num_triangles);
	quads = (quad *)malloc(sizeof(quad) * num_quads);
	material_sections = (material_section *)malloc(sizeof(material_section) * num_material_sections);

	memcpy(vertices+1, temp_vertices, sizeof(vec3) * num_vertices);
	memcpy(tex_coords+1, temp_tex_coords, sizeof(vec2) * num_tex_coords);
	memcpy(normals+1, temp_normals, sizeof(vec3) * num_normals);
	memcpy(triangles, temp_triangles, sizeof(triangle) * num_triangles);
	memcpy(quads, temp_quads, sizeof(quad) * num_quads);
	memcpy(material_sections, temp_material_sections, sizeof(material_section) * num_material_sections);

	/*printf("Vertices = %d\n", num_vertices);
	printf("Tex coords = %d\n", num_tex_coords);
	printf("Num Normals = %d\n", num_normals);
	printf("Num Triangles = %d\n", num_triangles);
	printf("Num Quads = %d\n", num_quads);
	printf("Num Material sections = %d\n", num_material_sections);*/

	/* delete temporary storage */
	free(temp_vertices);
	free(temp_tex_coords);
	free(temp_normals);
	free(temp_triangles);
	free(temp_quads);
	free(temp_material_sections);
	
	[self assembleEdges];
	[self generateFaceNormals];
	//[self generateTangentSpaces];
	
	flat_shading = FALSE;


	[self buildList];

	return self;

}



-(void)draw {


	int i, j;
	glBegin(GL_TRIANGLES);
	for (i=0; i<num_material_sections; i++) {
	
		for (j=material_sections[i].start_tri; j<material_sections[i].end_tri; j++) {
			
			/*vec2 u1 = difference_vec2(tex_coords[triangles[j].t2], tex_coords[triangles[j].t1]);
			vec2 u2 = difference_vec2(tex_coords[triangles[j].t3], tex_coords[triangles[j].t1]);
			float det = u1.coords[0] * u2.coords[1] - u2.coords[0] * u1.coords[1];
			float a1 =  u2.coords[1] / det;
			float b1 = -u1.coords[1] / det;
			float a2 = -u2.coords[0] / det;
			float b2 = u1.coords[0] / det;
			vec3 v1 = difference(vertices[triangles[j].v2], vertices[triangles[j].v1]);
			vec3 v2 = difference(vertices[triangles[j].v3], vertices[triangles[j].v1]);
			vec3 tangent1 = normalize(add_vec3(scalar_multiply(a1, v1), scalar_multiply(b1, v2)));
			vec3 tangent2 = normalize(add_vec3(scalar_multiply(a2, v1), scalar_multiply(b2, v2)));*/


				//glVertexAttrib3fvARB(1, tangent1.coords);
				//glVertexAttrib3fvARB(2, tangent2.coords);

				BOOL use_face_normal = flat_shading;
				if (triangles[j].n1 <= 0 || triangles[j].n1 >= num_normals) use_face_normal = TRUE;
				if (triangles[j].n2 <= 0 || triangles[j].n2 >= num_normals) use_face_normal = TRUE;
				if (triangles[j].n2 <= 0 || triangles[j].n2 >= num_normals) use_face_normal = TRUE;

				glTexCoord2fv(tex_coords[triangles[j].t1].coords);
				glNormal3fv(use_face_normal ? face_normals[triangles[j].fsn].coords : normals[triangles[j].n1].coords);
				glVertex3fv(vertices[triangles[j].v1].coords);
								
				glTexCoord2fv(tex_coords[triangles[j].t2].coords);
				glNormal3fv(use_face_normal ? face_normals[triangles[j].fsn].coords : normals[triangles[j].n2].coords);
				glVertex3fv(vertices[triangles[j].v2].coords);
								
				glTexCoord2fv(tex_coords[triangles[j].t3].coords);
				glNormal3fv(use_face_normal ? face_normals[triangles[j].fsn].coords : normals[triangles[j].n3].coords);
				glVertex3fv(vertices[triangles[j].v3].coords);
			

		}
	}
	glEnd();
	
	glBegin(GL_QUADS);

	for (i=0; i<num_material_sections; i++) {

		for (j=material_sections[i].start_quad; j<material_sections[i].end_quad; j++) {
			
			
			/*vec2 u1 = difference_vec2(tex_coords[quads[j].t2], tex_coords[quads[j].t1]);
			vec2 u2 = difference_vec2(tex_coords[quads[j].t4], tex_coords[quads[j].t1]);
			float det = u1.coords[0] * u2.coords[1] - u2.coords[0] * u1.coords[1];
			float a1 =  u2.coords[1] / det;
			float b1 = -u1.coords[1] / det;
			float a2 = -u2.coords[0] / det;
			float b2 = u1.coords[0] / det;
			vec3 v1 = difference(vertices[quads[j].v2], vertices[quads[j].v1]);
			vec3 v2 = difference(vertices[quads[j].v4], vertices[quads[j].v1]);
			vec3 tangent1 = normalize(add_vec3(scalar_multiply(a1, v1), scalar_multiply(b1, v2)));
			vec3 tangent2 = normalize(add_vec3(scalar_multiply(a2, v1), scalar_multiply(b2, v2)));*/
			

			//glVertexAttrib3fvARB(1, tangent1.coords);
			//glVertexAttrib3fvARB(2, tangent2.coords);

			BOOL use_face_normal = flat_shading;
			if (quads[j].n1 <= 0 || quads[j].n1 >= num_normals) use_face_normal = TRUE;
			if (quads[j].n2 <= 0 || quads[j].n2 >= num_normals) use_face_normal = TRUE;
			if (quads[j].n3 <= 0 || quads[j].n3 >= num_normals) use_face_normal = TRUE;
			if (quads[j].n4 <= 0 || quads[j].n4 >= num_normals) use_face_normal = TRUE;

			glTexCoord2fv(tex_coords[quads[j].t1].coords);
			glNormal3fv(use_face_normal ? face_normals[quads[j].fsn].coords : normals[quads[j].n1].coords);
			glVertex3fv(vertices[quads[j].v1].coords);
			
			glTexCoord2fv(tex_coords[quads[j].t2].coords);
			glNormal3fv(use_face_normal ? face_normals[quads[j].fsn].coords : normals[quads[j].n2].coords);
			glVertex3fv(vertices[quads[j].v2].coords);
			
			glTexCoord2fv(tex_coords[quads[j].t3].coords);
			glNormal3fv(use_face_normal ? face_normals[quads[j].fsn].coords : normals[quads[j].n3].coords);
			glVertex3fv(vertices[quads[j].v3].coords);
			
			glTexCoord2fv(tex_coords[quads[j].t4].coords);
			glNormal3fv(use_face_normal ? face_normals[quads[j].fsn].coords : normals[quads[j].n4].coords);
			glVertex3fv(vertices[quads[j].v4].coords);
											
		}
	}
	glEnd();

}

-(void)buildList {

	list = glGenLists( 1 );
	glNewList(list, GL_COMPILE);
	[self draw];
	glEndList();
	
}

-(void)drawList {
	glCallList(list);
}

-(void)dealloc {
	glDeleteLists(list, 1);
	free(material_sections);
	[super dealloc];
}

@end
