// Written by Nathan Devlin 10/1/19

// BlinnPhong Vertex Shader

// Highlight

#version 150

uniform mat4 u_Model;       // Model Matrix

uniform mat3 u_ModelInvTr;  // The inverse transpose of the model matrix.

uniform mat4 u_View;        // The matrix that defines the camera's transformation.
uniform mat4 u_Proj;        // The matrix that defines the camera's projection.

uniform vec4 u_CameraPos;   // vec4 holding the world position of the camera

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec2 vs_UV;

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr
out vec4 fs_LightVec;       // The direction of virtual light lies relative to to current vertex
out vec2 fs_UV;

out vec4 fs_CameraPos;
out vec4 fs_Pos;

void main()
{
    fs_UV = vs_UV;    // Pass the vertex UVs to the fragment shader for interpolation

    fs_Nor = normalize(vec4(u_ModelInvTr * vec3(vs_Nor), 0)); // Pass the vertex normals to the fragment shader for interpolation.
                                                              // Transform the geometry's normals by the inverse transpose of the
                                                              // model matrix.

    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_CameraPos = u_CameraPos; // Pass the world camera position to the fragment shader

    fs_Pos = modelposition;

    fs_LightVec = fs_CameraPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_Proj * u_View * modelposition;
}
