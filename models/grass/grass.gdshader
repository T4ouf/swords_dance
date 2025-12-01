shader_type spatial;
// disable backface culling
render_mode cull_disabled;
render_mode diffuse_toon;
render_mode specular_toon;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform vec3 windDir = vec3(-1.5,0.0,0.3);
uniform float windSpeed = 1.5;

varying vec3 worldPos;



// hash based 3d value noise
// function taken from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
float hash( float n ){
    return fract(sin(n)*43758.5453);
}

float noiseFast(vec3 x){
    // The noise function returns a value in the range -1.0f -> 1.0f
    vec3 p = floor(x);
    vec3 f = fract(x);

    f       = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;

    return mix(mix(mix( hash(n+0.0), hash(n+1.0),f.x),
                   mix( hash(n+57.0), hash(n+58.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}


void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 direction = (vec4(windDir, 1.0) * MODEL_MATRIX).xyz; // world space direction to model space
	direction.y = 0.0;
	float randomizedWindSpeed = (1.0 + noiseFast(direction)) * 0.5 * windSpeed;
	vec3 time = 0.25*(2.0+1.2*sin(TIME*randomizedWindSpeed)+randomizedWindSpeed*0.5) * direction;
	//vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	VERTEX += time * (UV.y);
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz * noiseScale).rgb;
	ALBEDO = mix(color, color2, 1.0-UV.y) * mix(color, color2, noiseLevel.r);
	
	// revert normals for backfaces
	float normalSide = (float(FRONT_FACING)*2.0)-1.0;
	mat3 normalFixMatrix = mat3(normalSide);
	NORMAL = normalFixMatrix*NORMAL;
}
