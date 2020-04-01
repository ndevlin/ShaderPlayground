#version 330

uniform sampler2D u_Texture; // The texture to be read from

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

layout(location = 0) out vec3 out_Col;

void main()
{
    // Material base color (before shading)
    vec4 diffuseColor = texture(u_Texture, fs_UV);

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting.

    // Compute final shaded color
    out_Col = vec3(diffuseColor.rgb * lightIntensity);

}
