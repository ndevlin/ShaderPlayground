// Written by Nathan Devlin 10/1/19

#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec2 fs_UV;

layout(location = 0) out vec3 out_Col;

void main()
{
    // Material color
    vec4 textureColor = texture(u_Texture, fs_UV);

    // Compute final shaded color
    out_Col = vec3(textureColor.rgb);

}
