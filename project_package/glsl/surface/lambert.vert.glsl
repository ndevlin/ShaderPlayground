#version 150

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering.

uniform mat3 u_ModelInvTr;  // The inverse transpose of the model matrix.


uniform mat4 u_View;        // The matrix that defines the camera's transformation.
uniform mat4 u_Proj;        // The matrix that defines the camera's projection.

in vec4 vs_Pos;

in vec4 vs_Nor;

in vec2 vs_UV;

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex.
out vec2 fs_UV;             // The UV of each vertex.


void main()
{
    fs_UV = vs_UV;    // Pass the vertex UVs to the fragment shader for interpolation

    fs_Nor = normalize(vec4(u_ModelInvTr * vec3(vs_Nor), 0)); // Pass the vertex normals to the fragment shader for interpolation.
                                                             // Transform the geometry's normals by the inverse transpose of the
                                                             // model matrix. This is necessary to ensure the normals remain
                                                             // perpendicular to the surface after the surface is transformed by
                                                             // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = (inverse(u_View) * vec4(0,0,0,1)) - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_Proj * u_View * modelposition;
}
