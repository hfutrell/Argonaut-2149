/*
 *  Common.h
 *  NewtonTest
 *
 *  Created by Holmes Futrell on 4/2/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

//#ifndef COMMON
//#define COMMON

#define NONE 0
#define TRIANGLE 1
#define QUAD 2

typedef struct _vec2{
	float coords[2];
} vec2;

typedef struct _vec2i {
	int coords[2];
} vec2i;

typedef struct _vec3 {
	float coords[3];
} vec3;

typedef struct _vec4{
	float coords[4];
} vec4;

typedef struct _triangle{
	int v1, v2, v3;
	int n1, n2, n3;
	int t1, t2, t3;
	int fsn;	/* flat shading normal, literally perpendicular to face */
} triangle;

typedef struct _quad{
	int v1, v2, v3, v4;
	int n1, n2, n3, n4;
	int t1, t2, t3, t4;
	int fsn;	/* flat shading normal, literally perpendicular to face */
} quad;

typedef struct _edge {
	int v1, v2; /* adjacent vertices */
	int t1, t2;	/* adjacent triangles */
	int face_type1, face_type2;
	int dir;
} edge;

extern void transpose_mat3(float *mat);

extern vec2 make_vec2(float x, float y);
extern vec3 make_vec3(float x, float y, float z);
extern vec4 make_vec4(float x, float y, float z, float w);

extern float mag(vec3 v);
extern float mag_vec2(vec2 v);

extern vec3 normalize(vec3 v);
extern vec2 normalize_vec2(vec2 v);

extern vec3 difference(vec3 v1, vec3 v2);
extern vec2 difference_vec2(vec2 v1, vec2 v2);
extern vec3 scalar_multiply(float a, vec3 v);
extern vec3 cross(vec3 v1, vec3 v2);
extern void set_translation(float matrix[16], vec3 v);
extern void identity_matrix(float matrix[16]);
extern vec3 zero_vector(void);
extern void describeVec3(vec3 v);
extern int equal_vec3(vec3 v1, vec3 v2);
extern float dot_vec3(vec3 v1, vec3 v2);
extern float dot_vec4(vec4 v1, vec4 v2);
extern void build_mat3(float *mat, vec3 v1, vec3 v2, vec3 v3);
extern vec3 add_vec3(vec3 v1, vec3 v2);
extern vec4 point_to_vector(vec3 p);
//#endif
