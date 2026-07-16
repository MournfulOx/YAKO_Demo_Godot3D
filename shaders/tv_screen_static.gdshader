shader_type spatial;
render_mode unshaded, cull_back;

uniform vec2 grid_size = vec2(24.0, 24.0);
uniform float flicker_speed : hint_range(1.0, 120.0) = 24.0;

float hash(vec2 p) {
	p  = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 34.5);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 cell = floor(UV * grid_size);
	float frame = floor(TIME * flicker_speed);
	float n = hash(cell + frame * 17.23);
	ALBEDO = vec3(n);
}
