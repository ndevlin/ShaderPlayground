// Written by Nathan Devlin 10/1/19

#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader
uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;

in vec4 fs_LightVec;
in vec2 fs_UV;

in vec3 fs_OrigPos; // Pass original position information

layout(location = 0) out vec3 out_Col;

void main()
{
    // Lambertian Shading
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    float diffuseTerm = dot(normalize(vec4(fs_Nor, 0)), normalize(fs_LightVec));

    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

    vec3 lambertian = vec3(diffuseColor.rgb * lightIntensity);


    // Make Model More Red the further stretched it is
    vec3 distFromOriginalPos = abs(fs_Pos - fs_OrigPos);

    float multFactor = length(distFromOriginalPos);

    multFactor *= multFactor;

    vec3 result = lambertian;

    result.x *= multFactor;

    result.x /= 2;

    result.x = max(result.x, lambertian.x);

    result.x = clamp(result.x, 0, 1);


    out_Col = result;

}
