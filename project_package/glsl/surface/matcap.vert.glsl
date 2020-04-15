// Written by Nathan Devlin 10/1/19

// Matcap Vertex Shader

#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec2 vs_UV;

out vec2 fs_UV;

void main()
{
    vec3 fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));
    fs_Nor = mat3(u_View) * fs_Nor;

    // Map the UV values to pass to frag shader to the normal positions
    fs_Nor = normalize(fs_Nor);
    fs_Nor.x = (fs_Nor.x + 1) / 2.f;
    fs_Nor.y = (fs_Nor.y + 1) / 2.f;
    fs_UV = vec2(fs_Nor);

    vec4 modelposition = u_Model * vs_Pos;
    gl_Position = u_Proj * u_View * modelposition;
}
