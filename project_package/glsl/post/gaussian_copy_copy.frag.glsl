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


void main()
{

    vec2 newCoord = -fs_UV + vec2(1.0);

    int numGhosts = 1;

    float ghostDispersal = 0.01;

    vec2 texelSize = 1.0 / vec2(textureSize(u_RenderedTexture, 0));

    float distortionAmount = 5;

    vec3 distortion = vec3(-texelSize.x * distortionAmount, 0.0, texelSize.x * distortionAmount);

    vec2 ghostVec = (vec2(0.5)  - fs_UV) * ghostDispersal;

    vec2 direction = normalize(ghostVec);

    vec4 scale = vec4(100.0, 100.0, 100.0, 1.0);

    vec4 bias = vec4(-0.99, -0.99, -0.99, 1.0);

    vec4 result = vec4(0.0);

    for(int i = 1; i <= numGhosts; i++)
    {
        vec2 offset = newCoord + ghostVec * float(i);

        float weight = length(vec2(0.5) - offset) / length(vec2(0.5));
        weight = pow(1.0 - weight, 2.0);

        //vec4 inColor = texture(u_RenderedTexture, offset);
        vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                         offset, direction, distortion), 1.0);

        if(inColor[0] + inColor[1] + inColor[2] > 2.5)
        {
            inColor = vec4(1.0, 1.0, 1.0, 1.0);
        }

        vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

        result += scaledValue * weight;
    }

    color = vec3(result);

    vec4 origColor = texture(u_RenderedTexture, fs_UV);

    if(origColor[0] + origColor[1] + origColor[2] > 2.5)
    {
        origColor = vec4(1.0, 1.0, 1.0, 1.0);
    }

    color += vec3(origColor);



    float haloWidth = 0.5;

    vec2 haloVec = normalize(ghostVec) * haloWidth;

    float haloWeight = length(vec2(0.5) - fract(fs_UV + haloVec)) / length(vec2(0.5));
    haloWeight = pow(1.0 - haloWeight, 5.0);


    //vec4 inColor = texture(u_RenderedTexture, fs_UV + haloVec);
    vec4 inColor = vec4(textureDistorted(u_RenderedTexture,
                     fs_UV + haloVec, direction, distortion), 1.0);

    if(inColor[0] + inColor[1] + inColor[2] > 2.5)
    {
        inColor = vec4(1.0, 1.0, 1.0, 1.0);
    }

    vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

    color += vec3(scaledValue * haloWeight);


}
