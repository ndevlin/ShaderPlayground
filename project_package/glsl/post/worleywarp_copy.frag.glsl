// Written by Nathan Devlin 10/16/19

// Pointillism Fragment Shader

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
vec2 WorleyNoise(vec2 uv)
{
    float gridSize = 100.0f;

    uv *= gridSize; // Size of grid

    vec2 closestPoint = vec2(1.f, 1.f);

    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.5;
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(uvInt + neighbor);
            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);

            // Test if dist <= minDist without branching
            int distIsLess = int(dist <= minDist);
            int distIsGreater = int(dist > minDist);
            closestPoint = (distIsGreater * closestPoint) + (distIsLess * ((point + uvInt) / gridSize));
            closestPoint[0] = (distIsGreater * closestPoint[0]) + (distIsLess * (closestPoint[0] + x / gridSize));
            closestPoint[1] = (distIsGreater * closestPoint[1]) + (distIsLess * (closestPoint[1] + y / gridSize));

            minDist = min(minDist, dist);
        }
    }
    return closestPoint;
}


void main()
{
    // Get the closest Worley point to this UV
    vec2 closestPoint = WorleyNoise(fs_UV);

    // Get the color of the uv at the Worley point
    color = vec3(texture(u_RenderedTexture, closestPoint));
}
