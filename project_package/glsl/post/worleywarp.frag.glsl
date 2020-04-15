// Written by Nathan Devlin 10/16/19

// Bubbles Worley Warp Fragment shader

#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;


// Helper functions

// Noise function: returns a given pseudorandom point for a given input
vec2 random2( vec2 p )
{
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                 dot(p, vec2(269.5,183.3))))
                 * 43758.5453);
}


// Returns the distance between the vec2 uv and the
// randomly generated point within its grid square
float WorleyNoise(vec2 uv)
{
    uv *= 25.0; // Size of grid
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.0;
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(uvInt + neighbor);
            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}


void main()
{
    // Change input to WorleyNoise based on the time: Makes bubbles move
    float offset = (((cos(u_Time / 100.f) + 1.f) / 2.f) + 1.f) / 4.f;
    offset = clamp(offset, 0.f, 1.f);

    // Get distance between this UV (modified by the offset) and the corresponding worley point
    float dist = WorleyNoise(fs_UV * offset);

    //Subtract the dist from 1 to make bubble bright at center and dark at edges
    float distMod = 1 - dist;

    // Make the contrast between center and edges of bubbles sharper
    distMod *= distMod;

    // Make the bubbles uniformly darker
    distMod -= 0.2;

    // Get the color of this UV, offest by dist: Gives bubble warping effect
    vec3 colorIn = vec3(texture(u_RenderedTexture, vec2(fs_UV[0] + dist / 10.f, fs_UV[1] + dist / 10.f)));

    // Add bubble highlights to the bubbles and output the color
    color = vec3(distMod + colorIn[0], distMod + colorIn[1], distMod + colorIn[2]);
}
