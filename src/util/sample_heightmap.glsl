#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(set = 0, binding=0, std430) restrict writeonly buffer HeightData {
	float heights[];
};

layout(set = 0, binding = 1) uniform sampler2D height_map;

layout(push_constant) uniform Params {
	vec2 world_center;
	float world_size;
	float map_res;
} params;

void main() {
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	if (id.x >= 128 || id.y >= 128) return;
	float texel_size = params.world_size / params.map_res;

	vec2 world_pos = params.world_center - vec2(64.0) + (vec2(id) * texel_size);

	vec2 uv = (world_pos + (params.world_size / 2.0)) / params.world_size;
	float h = texture(height_map, uv).r;
	heights[id.y * 128 + id.x] = h;
}
