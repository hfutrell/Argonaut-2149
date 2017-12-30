/*
 *  Common.c
 *  NewtonTest
 *
 *  Created by Holmes Futrell on 4/4/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */
#include "math.h"
#include "Common.h"
#include "string.h"
#include "stdio.h"

void describeVec3(vec3 v) {
	printf("Vec3 = %f, %f, %f\n", v.coords[0], v.coords[1], v.coords[2]);
}

void build_mat3(float *mat, vec3 v1, vec3 v2, vec3 v3) {
	
	mat[0] = v1.coords[0];
	mat[1] = v1.coords[1];
	mat[2] = v1.coords[2];

	mat[3] = v2.coords[0];
	mat[4] = v2.coords[1];
	mat[5] = v2.coords[2];

	mat[6] = v3.coords[0];
	mat[7] = v3.coords[1];
	mat[8] = v3.coords[2];

}

void swap(float *a, float *b) {
	int temp = *a;
	*a = *b;
	*b = temp;
}

void transpose_mat3(float *mat) {

	swap(&mat[1], &mat[3]);
	swap(&mat[2], &mat[6]);
	swap(&mat[5], &mat[7]);

}

int equal_vec3(vec3 v1, vec3 v2) {

	if (v1.coords[0] != v2.coords[0]) return 0;
	if (v1.coords[1] != v2.coords[1]) return 0;
	if (v1.coords[2] != v2.coords[2]) return 0;
	return 1;

}

extern vec3 scalar_multiply(float a, vec3 v) {
	return make_vec3(a * v.coords[0], a * v.coords[1], a * v.coords[2]);
}

vec4 point_to_vector(vec3 p) {
	vec4 v;
	v.coords[0] = p.coords[0];
	v.coords[1] = p.coords[1];
	v.coords[2] = p.coords[2];
	v.coords[3] = 0.0f;
	return v;
}

vec3 make_vec3(float x, float y, float z) {
	vec3 result;
	result.coords[0] = x;
	result.coords[1] = y;
	result.coords[2] = z;
	return result;
}

vec2 make_vec2(float x, float y) {
	vec2 result;
	result.coords[0] = x;
	result.coords[1] = y;
	return result;
}

extern vec4 make_vec4(float x, float y, float z, float w) {
	vec4 result;
	result.coords[0] = x;
	result.coords[1] = y;
	result.coords[2] = z;
	result.coords[3] = w;
	return result;

}

vec3 add_vec3(vec3 v1, vec3 v2) {
	return make_vec3(v1.coords[0] + v2.coords[0], v1.coords[1] + v2.coords[1], v1.coords[2] + v2.coords[2]);
}

float mag(vec3 v) {
	return sqrt(v.coords[0] * v.coords[0] + v.coords[1] * v.coords[1] + v.coords[2] * v.coords[2]); 
}

float mag_vec2(vec2 v) {
	return sqrt(v.coords[0] * v.coords[0] + v.coords[1] * v.coords[1]); 
}


float dot_vec3(vec3 v1, vec3 v2) {
	return v1.coords[0] * v2.coords[0] + v1.coords[1] * v2.coords[1] + v1.coords[2] * v2.coords[2];
}

float dot_vec4(vec4 v1, vec4 v2) {
	return v1.coords[0] * v2.coords[0] + v1.coords[1] * v2.coords[1] + v1.coords[2] * v2.coords[2] + v1.coords[3] * v2.coords[3];
}


vec3 normalize(vec3 v) {
	vec3 result;
	float inv = 1.0f / mag(v);
	result.coords[0] = inv * v.coords[0];
	result.coords[1] = inv * v.coords[1];
	result.coords[2] = inv * v.coords[2];
	return result;
}

vec2 normalize_vec2(vec2 v) {
	vec2 result;
	float inv = 1.0f / mag_vec2(v);
	result.coords[0] = inv * v.coords[0];
	result.coords[1] = inv * v.coords[1];
	return result;
}


vec3 difference(vec3 v1, vec3 v2) {
	vec3 result;
	result.coords[0] = v1.coords[0] - v2.coords[0];
	result.coords[1] = v1.coords[1] - v2.coords[1];
	result.coords[2] = v1.coords[2] - v2.coords[2];
	return result;
}

vec2 difference_vec2(vec2 v1, vec2 v2) {
	vec2 result;
	result.coords[0] = v1.coords[0] - v2.coords[0];
	result.coords[1] = v1.coords[1] - v2.coords[1];
	return result;
}


vec3 cross(vec3 v1, vec3 v2) {
	vec3 result;
	result.coords[0] = v1.coords[1] * v2.coords[2] - v1.coords[2] * v2.coords[1]; 
	result.coords[1] = v1.coords[2] * v2.coords[0] - v1.coords[0] * v2.coords[2]; 
	result.coords[2] = v1.coords[0] * v2.coords[1] - v1.coords[1] * v2.coords[0]; 
	return result;
}

void identity_matrix(float matrix[16]) {
	bzero(matrix, 16 * sizeof(float));
	matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0f;
}

void set_translation(float matrix[16], vec3 v) {
	matrix[12]	= v.coords[0];
	matrix[13]	= v.coords[1];
	matrix[14]	= v.coords[2];
	matrix[15]	= 1.0f;
}

extern vec3 zero_vector(void) {
	return make_vec3(0.0f, 0.0f, 0.0f);
}