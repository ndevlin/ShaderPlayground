// Written by Nathan Devlin 10/15/19

#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

uniform int u_Time;


void main()
{
    float offset = cos(u_Time / 100.f) / 1.5f;

    offset *= offset * offset;

    float red = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] - offset, fs_UV[1]))).r;

    float green = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] + offset, fs_UV[1]))).g;

    float blue = vec3(texture(u_RenderedTexture, fs_UV)).b;

    color = vec3(red, green, blue);
}
