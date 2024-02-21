shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);

//the offsets of where to draw the line
const vec2 OFFSETS[4] = {vec2(-1, 0), vec2(0, -1), vec2(0, 1), vec2(1, 0)};

// this grows the shape 1px in each direction (somehow)
void vertex() {
	VERTEX += sign(VERTEX);
}

void fragment() {
	vec2 uv = UV;
	vec2 size = TEXTURE_PIXEL_SIZE;
	float outline = 0.0;
	
	//this shrinks the texture back down to it's correct size
	vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(2.0));
	uv = (uv - texture_pixel_size) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
	
	//this loops through the offsets, and draws the outline if it's 1 off from a solid pixel
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, uv + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);
	
	//these are the width of the full vertex, with +2px on each side
	float w = (vec2(1.0) / TEXTURE_PIXEL_SIZE)[0] + 2.0;
	float h = (vec2(1.0) / TEXTURE_PIXEL_SIZE)[1] + 2.0;
	
	vec4 color = texture(TEXTURE, uv);
	/*check if this is the first or last pixel in x or y:
	  this is to deal with the fact that when we shrink the uv back down, 
	  it tiles the texture on the edges, making it look like those pixels 
	  on the edges are stretched - so we cover them with the outline color */
	if (UV[0] < 1.0/w || UV[0] > (1.0/w)*(w-1.0) || UV[1] < 1.0/h || UV[1] > (1.0/h)*(h-1.0) ) {
		//and if the pixel isn't transparent - fill it with the line
		if (color[3] > 0.0) { COLOR = line_color; }
		//otherwise just make it transparent
		else { COLOR = vec4(0.0,0.0,0.0,0.0); }
	//if its not along the edge, just draw the outline shader normally, which overlays the sprite onto the outline
	} else {
		COLOR = mix(color, line_color, outline - color.a);
	}
}	