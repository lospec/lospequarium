shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
const vec2 OFFSETS[4] = {vec2(-1, 0), vec2(0, -1), vec2(0, 1), vec2(1, 0)};

void vertex() {
	VERTEX += sign(VERTEX);
}

void fragment() {
	vec2 uv = UV;
	vec2 size = TEXTURE_PIXEL_SIZE;
	float outline = 0.0;

	vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(2.0));
	uv = (uv - texture_pixel_size) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
	
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, uv + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);
	
	float w = (vec2(1.0) / TEXTURE_PIXEL_SIZE)[0] + 2.0;
	float h = (vec2(1.0) / TEXTURE_PIXEL_SIZE)[1] + 2.0;
	
	vec4 color = texture(TEXTURE, uv);
	if (UV[0] < 1.0/w || UV[0] > (1.0/w)*(w-1.0) || UV[1] < 1.0/h || UV[1] > (1.0/h)*(h-1.0) ) {
		if (color[3] > 0.0) { COLOR = line_color; }
		else { COLOR = vec4(0.0,0.0,0.0,0.0); }
	} else {
		COLOR = mix(color, line_color, outline - color.a);
	}
}	