#version 150
// noOp.vert.glsl:
// A fragment shader used for post-processing that simply reads the
// image produced in the first render pass by the surface shader
// and outputs it to the frame buffer


in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

void main()
{
    color = texture(u_RenderedTexture, fs_UV).rgb;


    /*
    float near = 0.1;
    float far = 1000.f;

    float z = color.r * 2.0 - 1.0;
    float depth = (2.0 * near * far) / (far + near - z * (far - near));

    depth /= 10.f;

    color = vec3(depth);
    */
}
