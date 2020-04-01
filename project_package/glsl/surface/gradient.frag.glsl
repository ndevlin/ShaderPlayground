// Written by Nathan Devlin 10/1/19

#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec3 fs_Nor;
in vec3 fs_LightVec;

layout(location = 0) out vec3 out_Col;

void main()
{
    // t = commonality of normal vector with light/camera vector
    float t = dot(normalize(fs_Nor), normalize(fs_LightVec));

    // Avoid negative  values
    t = clamp(t, 0, 1);

    // These values give the specific color pallete, changing them changes the pallete
    vec3 a = vec3(0.5f, 0.5f, 0.5f);
    vec3 b = vec3(0.5f, 0.5f, 0.5f);
    vec3 c = vec3(1.f, 1.f, 1.f);
    vec3 d = vec3(0.f, 0.3333333f, 0.6666667f);

    vec3 color = a + b * cos( 6.2831853f * (c * t + d));

    out_Col = color;
}
