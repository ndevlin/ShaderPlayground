// Created by Adam Mally, modified by Nathan Devlin

#ifndef SHADERPROGRAM_H
#define SHADERPROGRAM_H

#include <openglcontext.h>
#include <la.h>
#include <glm/glm.hpp>

#include "drawable.h"
#include "texture.h"


class ShaderProgram
{
public:

    GLuint vertShader; // A handle for the vertex shader stored in this shader program
    GLuint fragShader; // A handle for the fragment shader stored in this shader program
    GLuint prog;       // A handle for the linked shader program stored in this class

    int unifSampler2D; // A handle to the uniform sampler2D that will be used to read the texture containing the scene render
    int unifTime; // A handle for the uniform float representing time in the shader

    int unifSampler2D_DepthText; // A handle to the uniform sampler2D that will be used to read the depth texture

    int unifModel; // A handle for the uniform mat4 representing model matrix in the vertex shader
    int unifModelInvTr; // A handle for the uniform mat4 representing inverse transpose of the model matrix in the vertex shader
    int unifView; // A handle for the uniform mat4 representing the view matrix in the vertex shader
    int unifProj; // A handle for the uniform mat4 representing the projection matrix in the vertex shader

    int unifProjInv; // A handle for the uniform mat4 representing the inverse of the projection matrix in the vertex shader

    int attrCamPos; // A handle for the uniform vec3 representing the camera position in world space

    //Used for MotionBlur
    int unifCurrentToPrevMat;

    int unifInverseViewMat;


public:
    ShaderProgram(OpenGLContext* context);

    virtual ~ShaderProgram();

    // Sets up the requisite GL data and shaders from the given .glsl files
    void create(const char *vertfile, const char *fragfile);

    // Sets up shader-specific handles
    virtual void setupMemberVars() = 0;

    // Tells our OpenGL context to use this shader to draw things
    void useMe();

    // Draw the given object to our screen using this ShaderProgram's shaders
    virtual void draw(Drawable &d, int textureSlot) = 0;

    // Utility function used in create()
    char* textFileRead(const char*);

    QString qTextFileRead(const char*);

    // Utility function that prints any shader compilation errors to the console
    void printShaderInfoLog(int shader);

    // Utility function that prints any shader linking errors to the console
    void printLinkInfoLog(int prog);

    void setTime(int t);


    // Pass the given model matrix to this shader on the GPU
    void setModelMatrix(const glm::mat4 &model);

    // Pass the given Projection * View matrix to this shader on the GPU
    void setViewProjMatrix(const glm::mat4 &v, const glm::mat4 &p, const glm::mat4 &pInv,
                           const glm::mat4 &i, const glm::mat4 &prev);

    // Helper function to set the camera position variable in the shader, if it exists
    void setGPUCamPos(const int handle, const glm::vec4 &camPos);


protected:
    OpenGLContext* context;   // Since Qt's OpenGL support is done through classes like QOpenGLFunctions_3_2_Core,
                            // we need to pass our OpenGL context to the Drawable in order to call GL functions
                            // from within this class.
};


#endif // SHADERPROGRAM_H
