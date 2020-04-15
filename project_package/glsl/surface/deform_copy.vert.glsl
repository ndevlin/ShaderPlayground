// Written by Nathan Devlin 10/1/19

// Stretchy Model Vertex Shader

#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

in vec2 vs_UV;


out vec3 fs_Pos;
out vec3 fs_Nor;

out vec4 fs_LightVec;

out vec3 fs_OrigPos;  // Pass original position information

out vec2 fs_UV;


void main()
{
    // Setup for Lambertian shading
    fs_UV = vs_UV;

    vec4 modelposition = u_Model * vs_Pos;

    fs_LightVec = (inverse(u_View) * vec4(0,0,0,1)) - modelposition;

    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));

    modelposition /= 2.0; // Shrink model in half to account for stretching

    fs_OrigPos = vec3(modelposition / 2);

    // Create a sphere of radius 1
    vec4 distFromOrigin = modelposition - vec4(0, 0, 0, 1);

    vec4 spherePoint = 1 * normalize(distFromOrigin);

    vec4 modelCopy = modelposition;

    modelCopy += 2 * (modelposition - spherePoint);

    vec4 result = vec4(1, 1, 1, 1);

    // Interpolate between stretched version and original model based on time
    result.x = mix(modelCopy.x, modelposition.x, abs(sin(u_Time * 0.01)));

    result.y = mix(modelCopy.y, modelposition.y, abs(sin(u_Time * 0.01)));

    result.z = mix(modelCopy.z, modelposition.z, abs(sin(u_Time * 0.01)));

    fs_Pos = vec3(result + spherePoint);

    gl_Position = u_Proj * u_View * result;
}
