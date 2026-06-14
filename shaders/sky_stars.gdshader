shader_type sky;

// Sky gradient — match your WorldEnvironment colours
uniform vec3 color_top     : source_color = vec3(0.012, 0.012, 0.045);
uniform vec3 color_horizon : source_color = vec3(0.03,  0.015, 0.06);
uniform vec3 color_ground  : source_color = vec3(0.08,  0.04,  0.01);

// Stars
uniform float star_density   : hint_range(0.90, 1.00) = 0.968;
uniform float star_brightness : hint_range(0.0,  2.0)  = 0.65;
uniform float star_size      : hint_range(0.02, 0.3)   = 0.12;
uniform float twinkle_speed  : hint_range(0.0,  4.0)   = 0.9;

float hash(vec2 p) {
	p  = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 74.9);
	return fract(p.x * p.y);
}

void sky() {
	float h = EYEDIR.y;

	// Vertical gradient
	vec3 col;
	if (h >= 0.0) {
		col = mix(color_horizon, color_top, pow(h, 0.6));
	} else {
		col = mix(color_horizon, color_ground, pow(-h, 0.4));
	}

	// Stars — only upper hemisphere, fade near horizon
	float star_mask = smoothstep(-0.04, 0.18, h);
	if (star_mask > 0.0) {
		// Spherical grid
		float phi   = atan(EYEDIR.x, EYEDIR.z);
		float theta = asin(clamp(EYEDIR.y, -1.0, 1.0));
		vec2 uv     = vec2(phi / (PI * 2.0), theta / PI) * 110.0;

		vec2 cell = floor(uv);
		vec2 f    = fract(uv);

		float stars = 0.0;
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				vec2 nb  = vec2(float(i), float(j));
				vec2 c   = cell + nb;
				float rnd = hash(c);
				if (rnd > star_density) {
					// Place star at random position within cell
					vec2 pos    = nb + vec2(hash(c + 3.7), hash(c + 8.1)) * 0.8 + 0.1;
					float dist  = length(f - pos);
					float blink = 0.88 + 0.12 * sin(TIME * twinkle_speed + rnd * 31.4);
					stars += step(dist, star_size) * blink;
				}
			}
		}
		col += vec3(stars) * star_brightness * star_mask;
	}

	COLOR = col;
}
