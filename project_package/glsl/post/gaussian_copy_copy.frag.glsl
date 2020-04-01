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
    vec4 result = texture(u_RenderedTexture, fs_UV);

    color = vec3(result);

    if(color[0] + color[1] + color[2] > 2.5)
    {
        color = vec3(1.0, 1.0, 1.0);
    }

}
