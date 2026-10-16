shader_type canvas_item;

void vertex() {
}

uniform float xSpeed=0.1;
uniform float ySpeed=0.1;
uniform float timeSpeed=0.2;

void fragment() {
	vec4 textureColor = texture(TEXTURE, UV+vec2(xSpeed, ySpeed)*TIME*timeSpeed);
	COLOR = textureColor;
}
