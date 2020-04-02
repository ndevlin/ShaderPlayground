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

void main()
{

    vec2 newCoord = -fs_UV + vec2(1.0);

    int numGhosts = 1;

    float ghostDispersal = 0.1;

    vec2 texelSize = 1.0 / vec2(textureSize(u_RenderedTexture, 0));

    vec2 ghostVec = (vec2(0.5)  - fs_UV) * ghostDispersal;

    vec4 scale = vec4(10.0, 10.0, 10.0, 1.0);

    vec4 bias = vec4(-0.9, -0.9, -0.9, 1.0);

    vec4 result = vec4(0.0);

    for(int i = 1; i <= numGhosts; i++)
    {
        vec2 offset = newCoord + ghostVec * float(i);

        //vec4 inColor = texture(u_RenderedTexture, fs_UV);
        vec4 inColor = texture(u_RenderedTexture, offset);

        if(inColor[0] + inColor[1] + inColor[2] > 2.5)
        {
            inColor = vec4(1.0, 1.0, 1.0, 1.0);
        }

        vec4 scaledValue = max(vec4(0.0), inColor + bias) * scale;

        result += scaledValue / 2.0;
    }

    color = vec3(result);

    vec4 origColor = texture(u_RenderedTexture, fs_UV);

    color += vec3(origColor);
}
