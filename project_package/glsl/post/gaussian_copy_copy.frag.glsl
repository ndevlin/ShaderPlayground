// Written by Nathan Devlin 4/20/20

#version 150

in vec2 fs_UV;
in vec4 fs_CameraPos;

out vec3 color;

uniform int u_Time;
uniform ivec2 u_Dimensions;

uniform mat4 u_Proj;        // The matrix that defines the camera's projection.
uniform mat4 u_ProjInv;        // Inverse of the projection matrix

uniform mat4 u_CurrentToPrevMat;
uniform mat4 u_InverseViewMat;

uniform sampler2D u_RenderedTexture;
uniform sampler2D u_DepthTexture;


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
float noise2D(vec2 n)
{
    float toReturn = (fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453));

    return 10.0 * pow(toReturn, 1000.0);
}

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



float linearNoise(float xCoord)
{
    //return fract(sin(xCoord * 100 * 3.14159265359) * 1.5);

    return fract(sin(int(xCoord * 2500) % 1234) * 1);
}


vec3 coloredLinearNoise(float xCoord)
{
    vec3 result = vec3(0.0);


    result[0] = sin(12 * (xCoord - 0.3));

    result[1] = cos(8 * (xCoord - 0.2)) + sin(8 * (xCoord - 0.2)) - 0.5;

    result[2] = cos(6 * (xCoord - 0.1));

    result -= vec3(0.2, 0.2, 0.2);

    result = clamp(result, 0.0, 0.8);

    result += vec3(0.4, 0.4, 0.4);

    return result;
}





void main()
{
    // Set colors near white to pure - only for testing purposes

    vec4 origColor = texture(u_RenderedTexture, fs_UV);

    if(origColor[0] + origColor[1] + origColor[2] > 2.8)
    {
        origColor = vec4(1.0, 1.0, 1.0, 1.0);
    }

    color = vec3(origColor);





    vec2 newCoord = -fs_UV + vec2(1.0);

    int numGhosts = 1;

    float ghostDispersal = 0.5;//0.01;

    vec2 texelSize = 1.0 / vec2(textureSize(u_RenderedTexture, 0));

    float distortionAmount = 7;

    vec3 distortion = vec3(-texelSize.x * distortionAmount, 0.0, texelSize.x * distortionAmount);

    vec2 ghostVec = (vec2(0.5)  - fs_UV) * ghostDispersal;

    vec2 direction = normalize(ghostVec);

    vec4 scale = vec4(100.0, 100.0, 100.0, 1.0);

    vec4 bias = vec4(-0.99, -0.99, -0.99, 1.0);

    vec4 lensFlare = vec4(0.0);



    float starBurstOffset = (fs_CameraPos[0] + fs_CameraPos[1] + fs_CameraPos[2]) / 10000.0;

    vec2 centerVec = fs_UV - vec2(0.5);
    float d = length(centerVec);
    float radians = acos(centerVec.x / d) / (2.0 * 3.14159265359);


    float mask = linearNoise(radians + starBurstOffset) * linearNoise(radians - starBurstOffset * 0.5);

    //float mask = linearNoise(radians);


    mask = clamp(mask + (1.0 - smoothstep(0.0, 0.3, d)), 0.0, 1.0);

    mask *= (0.5 / d);

    mask *= mask;

    mask = clamp(mask, 0.0, 1.0);




    for(int i = 1; i <= numGhosts; i++)
    {
        vec2 offset = newCoord + ghostVec * float(i);

        float weight = length(vec2(0.5) - offset) / length(vec2(0.5));
        weight = pow(1.0 - weight, 2.0);

        //vec4 inColor = texture(u_RenderedTexture, offset);
        // Chromatic Abberation
        vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                         offset, direction, distortion), 1.0);

        // Set colors near white to pure white, for testing purposes
        if(inColor[0] + inColor[1] + inColor[2] > 2.8)
        {
            inColor = vec4(1.0, 1.0, 1.0, 1.0);
        }

        vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

        scaledValue *= vec4(coloredLinearNoise(d), 1.0);

        lensFlare += scaledValue * weight;
    }

    //color = vec3(result);




    float haloWidth = 0.5;

    vec2 haloVec = normalize(ghostVec) * haloWidth;

    float haloWeight = length(vec2(0.5) - fract(fs_UV + haloVec)) / length(vec2(0.5));
    haloWeight = pow(1.0 - haloWeight, 5.0);


    //vec4 inColor = texture(u_RenderedTexture, fs_UV + haloVec);
    // Chromatic Abberation
    vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                     fs_UV + haloVec, direction, distortion), 1.0);

    // Set colors near white to pure white, for testing purposes
    if(inColor[0] + inColor[1] + inColor[2] > 2.8)
    {
        inColor = vec4(1.0, 1.0, 1.0, 1.0);
    }


    vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

    scaledValue *= vec4(coloredLinearNoise(d), 1.0);



    float dustVal = 100.0 * pow(clamp(fbm(fs_UV[0], fs_UV[1]), 0.0, 0.9), 0.9);

    dustVal += 0.1;

    clamp(dustVal, 0.0, 1.0);

    dustVal = sqrt(dustVal);


    vec3 postDustHaloColor = dustVal * vec3(scaledValue * haloWeight);

    lensFlare *= dustVal;

    lensFlare += vec4(postDustHaloColor, 0.0);



    lensFlare = ((mask * lensFlare) + (1.0 * lensFlare)) / 2.0;


    lensFlare = clamp(lensFlare, 0.0, 1.0);

    lensFlare *= 0.75;


    color += vec3(lensFlare);


    //color = vec3(dustVal);






    color = coloredLinearNoise(d);

    color = clamp(color + (1.0 - smoothstep(0.1, 0.3, d)), 0.0, 1.0);

}


