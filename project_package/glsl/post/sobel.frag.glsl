// Written by Nathan Devlin 10/16/19

#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;


void main()
{
    float horizontalStep = 1.f / u_Dimensions[1];
    float verticalStep = 1.f / u_Dimensions[0];

    // Get original pixel colors of 9 pixels about current pixel
    vec3 pix0 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] - horizontalStep,
                             fs_UV[1] + verticalStep)));
    vec3 pix1 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0],
                             fs_UV[1] + verticalStep)));
    vec3 pix2 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] + horizontalStep,
                             fs_UV[1] + verticalStep)));
    vec3 pix3 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] - horizontalStep,
                             fs_UV[1])));
    vec3 pix4 = vec3(texture(u_RenderedTexture, fs_UV));
    vec3 pix5 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] + horizontalStep,
                             fs_UV[1])));
    vec3 pix6 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] - horizontalStep,
                             fs_UV[1] - verticalStep)));
    vec3 pix7 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0],
                             fs_UV[1] - verticalStep)));
    vec3 pix8 = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] + horizontalStep,
                             fs_UV[1] - verticalStep)));

    // Calculate horizontal gradient
    vec3 hGradPix0 = 3.f * pix0;
    vec3 hGradPix1 = 0.f * pix1;
    vec3 hGradPix2 = -3.f * pix2;
    vec3 hGradPix3 = 10.f * pix3;
    vec3 hGradPix4 = 0.f * pix4;
    vec3 hGradPix5 = -10.f * pix5;
    vec3 hGradPix6 = 3.f * pix6;
    vec3 hGradPix7 = 0.f * pix7;
    vec3 hGradPix8 = -3.f * pix8;

    vec3 hDelta = hGradPix0 + hGradPix1 + hGradPix2 + hGradPix3 +
            hGradPix4 + hGradPix5 + hGradPix6 + hGradPix7 + hGradPix8;

    // Calculate Vertical Gradiant
    vec3 vGradPix0 = 3.f * pix0;
    vec3 vGradPix1 = 10.f * pix1;
    vec3 vGradPix2 = 3.f * pix2;
    vec3 vGradPix3 = 0.f * pix3;
    vec3 vGradPix4 = 0.f * pix4;
    vec3 vGradPix5 = 0.f * pix5;
    vec3 vGradPix6 = -3.f * pix6;
    vec3 vGradPix7 = -10.f * pix7;
    vec3 vGradPix8 = -3.f * pix8;

    vec3 vDelta = vGradPix0 + vGradPix1 + vGradPix2 + vGradPix3 +
            vGradPix4 + vGradPix5 + vGradPix6 + vGradPix7 + vGradPix8;

    // Set color to be length of gradient vector for each channel
    color[0] = sqrt(vDelta[0] * vDelta[0] + hDelta[0] * hDelta[0]);
    color[1] = sqrt(vDelta[1] * vDelta[1] + hDelta[1] * hDelta[1]);
    color[2] = sqrt(vDelta[2] * vDelta[2] + hDelta[2] * hDelta[2]);
}

