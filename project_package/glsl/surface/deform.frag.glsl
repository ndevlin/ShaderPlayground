// Written by Nathan Devlin 10/1/19

// Spherical Deformation Fragment Shader

//

#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader
uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;

layout(location = 0) out vec3 out_Col;

void main()
{

    // Ensure that color values will be between 0 and 1
    vec3 result = normalize(fs_Pos);

    // Change the color based on the normal position, modulated by time
    result.x = result.x + ((1 + sin(u_Time * 0.05) / 2.f));
    result.y = result.y + ((1 + cos(u_Time * 0.05) / 2.f));
    result.z = result.z + ((1 + sin(u_Time * 0.05) / 2.f));

    result = normalize(result);

    out_Col = result;

}
