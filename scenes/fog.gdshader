shader_type canvas_item;

uniform vec4 baseColor : source_color;
uniform float fogIntensity = 1.0f;
uniform float fogSpeed = 1.0f;
//global uniform float location_fade;

void fragment() {
	vec3 fogLayer1 = texture(TEXTURE, 
						vec2(	UV.x*0.5 + TIME*fogSpeed*0.01, 
								UV.y*0.25 - TIME*fogSpeed*0.01)).rgb;
						
	vec3 fogLayer2 = texture(TEXTURE, 
						vec2(	UV.x*0.5 + 0.5 + TIME*fogSpeed*0.02,
								UV.y*0.25+ 0.5 - TIME*fogSpeed*0.00625)).rgb;
						
	vec3 fogLayer3 = texture(TEXTURE, 
						vec2(	UV.x*0.5 + 0.25 + TIME*fogSpeed*0.04,
								UV.y*0.25- 0.25 + TIME*fogSpeed*0.00625)).rgb;
	vec3 fogColorFinal = mix(fogLayer3, mix(fogLayer1, fogLayer2, 0.5), 0.7);
	COLOR.a *= baseColor.a * fogColorFinal.r * fogIntensity;
	COLOR.rgb = fogColorFinal * baseColor.rgb;
//	COLOR
}