shader_type spatial;
uniform sampler2D height_map: filter_nearest;
uniform float world_size = 2048.0;
uniform float vertex_spacing = 1.0;
varying vec2 map_uv;
void vertex() {
	// Called for every vertex the material is visible on.
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 snapped = floor(world_pos.xz / vertex_spacing) * vertex_spacing;
	map_uv = (snapped+ (world_size / 2.0)) / world_size;
	float height = textureLod(height_map, map_uv, 0).r;
	VERTEX.y += height * 30.0;
}

void fragment() {
	vec4 tex = texture(height_map, map_uv);
	ALBEDO = tex.rgb;
}