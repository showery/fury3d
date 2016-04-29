#version 330

#ifdef VERTEX_SHADER

in vec3 vertex_position;
in vec3 vertex_normal;

#ifdef SKINNED_MESH
in ivec4 bone_ids;
in vec3 bone_weights;
uniform mat4 bone_matrices[35];
#endif

out vec3 out_normal;
out float out_depth;

uniform mat4 projection_matrix;
uniform mat4 invert_view_matrix;
uniform mat4 world_matrix;

void main()
{
#ifdef SKINNED_MESH
	mat4 bone_matrix = bone_matrices[bone_ids[0]] * bone_weights[0];
	bone_matrix += bone_matrices[bone_ids[1]] * bone_weights[1];
	bone_matrix += bone_matrices[bone_ids[2]] * bone_weights[2];
	bone_matrix += bone_matrices[bone_ids[3]] * (1.0f - bone_weights[0] - bone_weights[1] - bone_weights[2]);
	vec4 worldPos = world_matrix * bone_matrix * vec4(vertex_position, 1.0);
	out_normal = normalize(invert_view_matrix * world_matrix * bone_matrix * vec4(vertex_normal, 0.0)).xyz;
#else
	vec4 worldPos = world_matrix * vec4(vertex_position, 1.0);
	out_normal = normalize(invert_view_matrix * world_matrix * vec4(vertex_normal, 0.0)).xyz;
#endif
	
	vec4 viewPos = invert_view_matrix * worldPos;
	out_depth = -viewPos.z;
	
	gl_Position = projection_matrix * viewPos;
}

#endif

#ifdef FRAGMENT_SHADER

in vec3 out_normal;
in float out_depth;

uniform float camera_far = 10000;
uniform float shininess = 0;

uniform vec3 ambient_color;
uniform vec3 diffuse_color;

uniform float ambient_factor = 1;
uniform float diffuse_factor = 1;

// normal.xyz, shininess
layout (location = 0) out vec4 rt0;
// diffuse rgb
layout (location = 1) out vec4 rt1;

void main()
{
	rt0.rgb = (out_normal.rgb + 1) * 0.5;
	rt0.a = shininess / 100;

	rt1.rgb = diffuse_color.rgb * diffuse_factor + ambient_color.rgb * ambient_factor;
	
	gl_FragDepth = out_depth / camera_far;
}

#endif