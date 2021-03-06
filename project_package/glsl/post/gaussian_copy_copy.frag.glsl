// Written by Nathan Devlin 4/15/20

// Lens Flare Fragment Shader

// Highlight

#version 150

in vec2 fs_UV;
in vec4 fs_CameraPos;

out vec3 color;

uniform sampler2D u_RenderedTexture;

// Simulates Chromatic Aberration by sampling each channel at an offset
vec3 textureDistorted(
        sampler2D tex,
        vec2 uvCoord,
        vec2 direction,  // direction of distortion
        vec3 distortion) // factor of distortion per channel
{
    return vec3(
                texture(tex, uvCoord + direction * distortion.r).r,
                texture(tex, uvCoord + direction * distortion.g).g,
                texture(tex, uvCoord + direction * distortion.b).b
                );
}


// Takes in a vec2 and generates a pseudorandom but consistent value for it
// Used to procedurally generate a dust texture
float noise2D(vec2 n)
{
    float toReturn = fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);

    return 10.0 * pow(toReturn, 1000.0);
}


//Takes in x and y values and uses them to create an interpolated noise value
float interpNoise2D(float x, float y)
{
    int intX = int(floor(x));
    float fractX = fract(x);
    int intY = int(floor(y));
    float fractY = fract(y);

    float v1 = noise2D(vec2(intX, intY));
    float v2 = noise2D(vec2(intX + 1, intY));
    float v3 = noise2D(vec2(intX, intY + 1));
    float v4 = noise2D(vec2(intX + 1, intY + 1));

    v1 = cos((1.0 - v1) * 3.14159265359 * 0.5);
    v2 = cos((1.0 - v2) * 3.14159265359 * 0.5);
    v3 = cos((1.0 - v3) * 3.14159265359 * 0.5);
    v4 = cos((1.0 - v4) * 3.14159265359 * 0.5);

    fractX = fractX * fractX * (3.0 - (2.0 * fractX));

    fractY = fractY * fractY * (3.0 - (2.0 * fractY));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);

    i1 = i1 * i1 * (3.0 - (2.0 * i1));
    i2 = i2 * i2 * (3.0 - (2.0 * i2));

    return mix(i1, i2, fractY);
}


// Fractal Brownian Motion noise algorithm
float fbm(float x, float y)
{
    float total = 0;
    float persistence = 0.5f;
    int octaves = 8;

    for(int i = 1; i <= octaves; i++)
    {
        float freq = pow(2.f, i);
        float amp = pow(persistence, i);

        total += interpNoise2D(x * freq, y * freq) * amp;
    }
    return total;
}


// Returns a pseudorandom number that is consistent based on input
// Procedurally emulates a 1-D black and white random texture
float linearNoise(float xCoord)
{
    return fract(sin(int(xCoord * 2500) % 1234));
}


// Procedurally simulates a 1-D rainbow texture
vec3 coloredRainbow(float xCoord)
{
    vec3 result = vec3(0.0);

    result[0] = sin(12.0 * (xCoord - 0.3));

    result[1] = cos(8.0 * (xCoord - 0.2)) + sin(8.0 * (xCoord - 0.2)) - 0.5;

    result[2] = cos(6.0 * (xCoord - 0.1));

    // Desaturate and brighten the result
    result -= vec3(0.2, 0.2, 0.2);
    result = clamp(result, 0.0, 0.8);
    result += vec3(0.4, 0.4, 0.4);

    return result;
}


// Returns a color value for the flare that should appear at this UV coordinate
vec3 lensFlare(vec2 uvIn)
{
    vec4 lensFlare = vec4(0.0);

    // Mirrors bright spots across the center of the image
    vec2 newCoord = -uvIn + vec2(1.0);

    // Number of repeated ghosts of bright spots
    int numGhosts = 5;

    float ghostDispersal = 0.5;

    vec2 texelSize = 1.0 / vec2(textureSize(u_RenderedTexture, 0));

    // Amount of Chromatic Aberration
    float distortionAmount = 7;

    vec3 distortion = vec3(-texelSize.x * distortionAmount, 0.0, texelSize.x * distortionAmount);

    vec2 ghostVec = ghostDispersal * (vec2(0.5) - uvIn);

    vec2 direction = normalize(ghostVec);

    // Determines threshold for what parts of image flare
    // With these values, the brightest 0.1% of colors will flare
    vec4 scale = vec4(1000.0, 1000.0, 1000.0, 1.0);
    vec4 bias = vec4(-0.999, -0.999, -0.999, 1.0);


    // Determine distance of the fragment to center of the image
    vec2 centerVec = uvIn - vec2(0.5);
    float d = length(centerVec);

    // Calculate the angle from the horizon to this fragment
    float radians = acos(centerVec.x / d) / (2.0 * 3.14159265359);


    // Modulate the starburst pattern when the camera moves
    float starBurstOffset = (fs_CameraPos[0] + fs_CameraPos[1] + fs_CameraPos[2]) / 2000.0;

    // Create a mask based on the diffraction pattern
    float mask = linearNoise(radians + starBurstOffset) * linearNoise(radians - starBurstOffset * 0.5);
    mask = clamp(mask + (1.0 - smoothstep(0.0, 0.3, d)), 0.0, 1.0);
    mask *= (0.5 / d);
    mask *= mask;
    mask = clamp(mask, 0.0, 1.0);

    //Get the color value for the simulated circular rainbow texture at this fragment
    vec3 rainbowTex = coloredRainbow(d);

    rainbowTex = clamp(rainbowTex + (1.0 - smoothstep(0.1, 0.3, d)), 0.0, 1.0);


    for(int i = 1; i <= numGhosts; i++)
    {
        vec2 offset = newCoord + ghostVec * float(i);

        float weight = length(vec2(0.5) - offset) / length(vec2(0.5));
        weight = pow(1.0 - weight, 2.0);

        //vec4 inColor = texture(u_RenderedTexture, offset);
        // Chromatic Aberration
        vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                         offset, direction, distortion), 1.0);

        // Set colors of input texture near white to pure white, for testing purposes
        if(inColor[0] + inColor[1] + inColor[2] > 2.8)
        {
            inColor = vec4(1.0, 1.0, 1.0, 1.0);
        }

        vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

        scaledValue *= vec4(rainbowTex, 1.0);

        lensFlare += scaledValue * weight;
    }


    // Create a lens halo at exterior of image

    float haloWidth = 0.5;

    vec2 haloVec = normalize(ghostVec) * haloWidth;

    float haloWeight = length(vec2(0.5) - fract(uvIn + haloVec)) / length(vec2(0.5));
    haloWeight = pow(1.0 - haloWeight, 5.0);

    //vec4 inColor = texture(u_RenderedTexture, fs_UV + haloVec);
    // Chromatic Aberration
    vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                     uvIn + haloVec, direction, distortion), 1.0);

    // Set colors of input texture near white to pure white, for testing purposes
    if(inColor[0] + inColor[1] + inColor[2] > 2.8)
    {
        inColor = vec4(1.0, 1.0, 1.0, 1.0);
    }

    // Only create halos for parts of the image brighter than the threshold
    vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

    // Modulate the halo by the simulated rainbow texture
    scaledValue *= vec4(rainbowTex, 1.0);

    lensFlare += scaledValue * haloWeight;


    // Modulate the flare by the simulated dust texture
    float dustVal = 100.0 * pow(clamp(fbm(uvIn[0], uvIn[1]), 0.0, 0.9), 0.9);
    dustVal += 0.1;
    clamp(dustVal, 0.0, 1.0);
    dustVal = sqrt(dustVal);
    lensFlare *= dustVal;

    // Modulate the flare by the diffraction pattern
    lensFlare = ((mask * lensFlare) + (1.0 * lensFlare)) / 2.0;

    lensFlare = clamp(lensFlare, 0.0, 1.0);

    // Decrease brightness of flare to make it more subtle
    //lensFlare *= 0.75;

    return vec3(lensFlare);
}


void main()
{
    vec4 origColor = texture(u_RenderedTexture, fs_UV);

    // Set colors near white to pure white - only for testing purposes
    if(origColor[0] + origColor[1] + origColor[2] > 2.8)
    {
        origColor = vec4(1.0, 1.0, 1.0, 1.0);
    }

    color = vec3(origColor);


    color += lensFlare(fs_UV);

    /*
    // Gaussian Blur on lens flare
    // Quickly implemented Gaussian Blur on flaring; slows down performance noticably
    // Texture-based blurring would be much better
    float offset[3] = float[](0.0, 1.3846153846, 3.2307692308);

    for (int i=1; i<3; i++)
    {
        color += lensFlare(fs_UV + vec2(0.0, offset[i] / u_Dimensions));

        color += lensFlare(fs_UV - vec2(0.0, offset[i] / u_Dimensions));
    }
    */

}


