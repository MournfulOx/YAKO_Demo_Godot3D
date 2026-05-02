shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D dither_tex : hint_default_white, repeat_enable, filter_nearest;
uniform float col_depth = 15.0;
uniform bool dither_banding = true;

void fragment() {
	vec4 base_color = texture(screen_texture, SCREEN_UV);
	vec2 dith_size = vec2(textureSize(dither_tex, 0));
	vec2 buf_size = vec2(textureSize(screen_texture, 0));
	vec3 dith = texture(dither_tex, SCREEN_UV * (buf_size / dith_size)).rgb - 0.5;
	COLOR.rgb = round(base_color.rgb * col_depth + dith * (dither_banding ? 1.0 : 0.0)) / col_depth;
	COLOR.a = 1.0;
}
