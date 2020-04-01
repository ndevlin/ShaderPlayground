// Written by Nathan Devlin 4/20/20

#version 150

in vec2 fs_UV;
in vec4 fs_CameraPos;

out vec3 color;

uniform int u_Time;
uniform ivec2 u_Dimensions;

uniform mat4 u_Proj;        // The matrix that defines the camera's projection.
uniform mat4 u_ProjInv;        // Inverse of the projection matrix

uniform mat4 u_CurrentToPrevMat;
uniform mat4 u_InverseViewMat;

uniform sampler2D u_RenderedTexture;
uniform sampler2D u_DepthTexture;

void main()
{

    // Get depth from depth texture
    vec4 depthVec = texture(u_DepthTexture, fs_UV);
    float depth = depthVec[0];

    // Linearize depth to give distance in world coords from camera
    float near = 0.1f;
    float far = 1000.f;

    float z = depth * 2.0 - 1.0;
    float worldDistFromCam = (1.0 * near * far) / (far + near - z * (far - near));


    vec4 screenPos = vec4(2 * fs_UV[0] - 1, 2 * fs_UV[1] - 1, depth, 1.f);


    vec4 cameraPos = vec4(0.f, 0.f, 0.f, 1.f);

    cameraPos.x = worldDistFromCam * (screenPos.x / u_Proj[0][0]);
    cameraPos.y = worldDistFromCam * (screenPos.y / u_Proj[1][1]);
    cameraPos.z = -1 * worldDistFromCam;


    vec4 previousScreenSpace = u_CurrentToPrevMat * cameraPos;
    previousScreenSpace.xyz /= previousScreenSpace.w;
    previousScreenSpace.xy = previousScreenSpace.xy * 0.5f + 0.5f;

    vec2 blurVec = previousScreenSpace.xy - fs_UV;

    // Original un-blurred image from texture saved in previous render pass
    vec4 result = texture(u_RenderedTexture, fs_UV);

    // Modify the magnitude of blur to achieve desired blur effect
    float blurMag = length(blurVec);
    blurVec = normalize(blurVec);

    blurMag = clamp(blurMag, 0.f, 0.1);
    blurMag *= ((blurMag * 10) * (blurMag * 10));
    blurMag /= (1.f + (worldDistFromCam / 100));

    blurVec = blurMag * blurVec;

    float divideFactor = 0.f;

    for(int i = 0; i < 32; i++)
    {
        vec2 offset = blurVec * ((float(i) / 31.f) - 0.5);

        float multFactor = 8 * ( 1.f / (abs(16.f - float(i)) + 1.f));

        divideFactor += multFactor;

        result += multFactor * texture(u_RenderedTexture, fs_UV + offset);
    }

    result /= 1 + divideFactor;


    color = vec3(result);

}
