// Written by Nathan Devlin 10/1/19

// Toon Fragment Shader

#version 330

uniform sampler2D u_Texture;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

in vec4 fs_CameraPos;
in vec4 fs_Pos;

layout(location = 0) out vec3 out_Col;

void main()
{
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

    vec4 viewVec = fs_CameraPos - fs_Pos;

    vec4 posToLight = fs_LightVec - fs_Pos;

    vec4 surfaceNorm = fs_Nor;

    vec4 H = (viewVec + posToLight) / (length(viewVec) + length(posToLight));

    float intensity =  7.f;

    float sharpness = 30.f;

    float specularIntensity = (intensity * max(pow(dot(H, surfaceNorm), sharpness), 0)) / 3.f;

    float finalIntensity = lightIntensity + specularIntensity;

    out_Col = vec3(diffuseColor.rgb * finalIntensity);

    // Discretize the color values
    out_Col[0] = ceil(out_Col[0] * 3.f) / 3.f;

    out_Col[0] = ceil(out_Col[0] * 3.f) / 3.f;

    out_Col[0] = ceil(out_Col[0] * 3.f) / 3.f;

}
