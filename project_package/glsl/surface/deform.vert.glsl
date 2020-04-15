// Written by Nathan Devlin 10/1/19

// Spherical Deformation Vertex Shader

#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec3 fs_Pos;
out vec3 fs_Nor;

void main()
{
    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));

    vec4 modelposition = u_Model * vs_Pos;

    // Create a sphere of radius 2; Map points from model to this sphere
    vec4 distFromOrigin = modelposition - vec4(0, 0, 0, 1);

    vec4 spherePoint = 2 * normalize(distFromOrigin);

    vec4 modelCopy = modelposition;

    // Interpolate between sphere and original model based on time
    modelCopy.x = mix(spherePoint.x, modelposition.x, abs(sin(u_Time * 0.01)));

    modelCopy.y = mix(spherePoint.y, modelposition.y, abs(sin(u_Time * 0.01)));

    modelCopy.z = mix(spherePoint.z, modelposition.z, abs(sin(u_Time * 0.01)));

    fs_Pos = vec3(spherePoint);

    gl_Position = u_Proj * u_View * modelCopy;
}
