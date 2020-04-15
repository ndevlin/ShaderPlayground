// Written by Nathan Devlin 10/16/19

// Bloom Fragment shader

#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

const float kernal[121] = float[121]
(0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799,  0.007941, 0.007795, 0.007559, 0.007239, 0.006849,
 0.007239, 0.007653, 0.00799,  0.00824,  0.008394, 0.008446, 0.008394, 0.00824,  0.00799,  0.007653, 0.007239,
 0.007559, 0.00799,  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799,  0.007559,
 0.007795, 0.00824,  0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824,  0.007795,
 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941,
 0.00799,  0.008446, 0.008819, 0.009095, 0.009265, 0.009322, 0.009265, 0.009095, 0.008819, 0.008446, 0.00799,
 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941,
 0.007795, 0.00824,  0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824,  0.007795,
 0.007559, 0.00799,  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799,  0.007559,
 0.007239, 0.007653, 0.00799,  0.00824,  0.008394, 0.008446, 0.008394, 0.00824,  0.00799,  0.007653, 0.007239,
 0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799,  0.007941, 0.007795, 0.007559, 0.007239, 0.006849);


float horizontalStep = 1.f / u_Dimensions[1];
float verticalStep = 1.f / u_Dimensions[0];

const float luminanceT = 0.6f;


void main()
{
    // Get the original UV color for this fragment
    vec3 colorIn = vec3(texture(u_RenderedTexture, fs_UV));

    vec3 outputColorAdd = vec3(0.f, 0.f, 0.f);

    // Calculate brightness to add based on surrounding pixels
    for(int r = -5; r < 5; r++)
    {
        for(int c = -5; c < 5; c++)
        {
            float weight = kernal[(r + 5) * 11 + (c + 5)];

            float xUV = fs_UV[0] + c * horizontalStep;

            float yUV = fs_UV[1] + r * verticalStep;

            vec3 colorAtCurrentPixel = vec3(texture(u_RenderedTexture,
                   vec2(xUV, yUV)));

            float luminance = (colorAtCurrentPixel[0] + colorAtCurrentPixel[1] +
                    colorAtCurrentPixel[2]);

            // Test if luminance is above the threshold
            int testAboveThreshold = int(luminance >= luminanceT);  // Will be 0 or 1
            outputColorAdd += testAboveThreshold * weight * colorAtCurrentPixel;
        }
    }

    color = colorIn + outputColorAdd;
}
