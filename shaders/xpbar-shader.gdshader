shader_type canvas_item;

uniform float percentFilled = 1;

void fragment() {
	if (UV[0] < percentFilled) {COLOR = texture(TEXTURE, UV);}
	else {COLOR = vec4(0.0,0.0,0.0,0.0);}
}