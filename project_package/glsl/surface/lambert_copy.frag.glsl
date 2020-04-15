// Written by Nathan Devlin 10/1/19

// Surface Noise Fragment Shader

#version 330

uniform sampler2D u_Texture;

uniform int u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

layout(location = 0) out vec3 out_Col;

// Noise function: returns a given pseudorandom point for a given input
vec2 random2( vec2 p )
{
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                 dot(p, vec2(269.5,183.3))))
                 * 43758.5453);
}


void main()
{
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.05;

    float lightIntensity = diffuseTerm + ambientTerm;

    float offset = cos(u_Time / 100.f) / 2.f;

    vec2 rand2 = random2(vec2(fs_UV[0] + offset, fs_UV[1]));

    float rand = rand2[0] / rand2[1];

    out_Col = vec3(diffuseColor.rgb * lightIntensity) * rand;

}
