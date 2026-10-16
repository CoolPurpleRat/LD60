shader_type canvas_item;

//Made by Persik, CC0
//Shader that removes one color.

instance uniform vec4 aWhatChange : source_color = vec4(1.000000, 1.000000, 1.000000, 1.000000);
/**How accurate is comparison. The smaller the more accurate. 1.0+ color full picture*/
instance uniform float cStrenght = float(0.0001);
/**How smooth transition from changed to normal. 0.0 no transition*/
instance uniform float dSmoothness = float(0.0);

void fragment() {
	float influence=smoothstep(cStrenght-dSmoothness, cStrenght, abs(length(COLOR.rgb - aWhatChange.rgb)) );
	
	COLOR.a=influence;
}

