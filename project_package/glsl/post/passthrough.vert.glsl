#version 150
// passthrough.vert.glsl:
// A vertex shader that simply passes along vertex data
// to the fragment shader without operating on it in any way.

in vec4 vs_Pos;
in vec2 vs_UV;

uniform vec4 u_CameraPos;   // vec4 holding the world position of the camera

out vec2 fs_UV;

out vec4 fs_CameraPos;

void main()
{
    fs_UV = vs_UV;

    fs_CameraPos = u_CameraPos; // Pass the world camera position to the fragment shader

    gl_Position = vs_Pos;
}
