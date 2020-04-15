// Written by Nathan Devlin 10/1/19

// Blinn Phong Fragment Shader

#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

in vec4 fs_CameraPos;
in vec4 fs_Pos;

layout(location = 0) out vec3 out_Col;

void main()
{

    // Lambertian shading
    // Material base color (before shading)
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Simulate ambient lighting.

    // Blinn-Phong Highlights
    vec4 viewVec = fs_CameraPos - fs_Pos;

    vec4 posToLight = fs_LightVec - fs_Pos;

    vec4 surfaceNorm = fs_Nor;

    vec4 H = (viewVec + posToLight) / (length(viewVec) + length(posToLight));

    float intensity =  7.f; // Relative intensity of highlight

    float sharpness = 30.f; // How sharp or spread out the highlight is

    float specularIntensity = intensity * max(pow(dot(H, surfaceNorm), sharpness), 0);

    float finalIntensity = lightIntensity + specularIntensity;

    // Compute final shaded color
    out_Col = vec3(diffuseColor.rgb * finalIntensity);

}
