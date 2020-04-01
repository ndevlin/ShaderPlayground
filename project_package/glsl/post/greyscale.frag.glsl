// Written by Nathan Devlin 10/15/19

#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;


uniform sampler2D u_DepthTexture;


void main()
{
    vec4 colorIn = texture(u_RenderedTexture, fs_UV);

    float grey = 0.21 * colorIn[0] + 0.72 * colorIn[1] + 0.07 * colorIn[2];

    // For vignette
    float distFromCenter = sqrt((fs_UV[0] - 0.5f) * (fs_UV[0] - 0.5f)
            + (fs_UV[1] - 0.5f) * (fs_UV[1] - 0.5f));

    distFromCenter *= 2.f / sqrt(2.f);

    distFromCenter = 1.f - distFromCenter;

    grey *= distFromCenter;

    color[0] = grey;
    color[1] = grey;
    color[2] = grey;

}
