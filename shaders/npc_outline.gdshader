shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform float outline_width : hint_range(0.0, 0.05) = 0.012;

void vertex() {
	vec4 pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 n   = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);
	pos.xyz += n * outline_width;
	POSITION = PROJECTION_MATRIX * pos;
}

void fragment() {
	ALBEDO = vec3(1.0);
}
