#pragma once

#include <QString>

#include "shaderprogram.h"


class SurfaceShader : public ShaderProgram
{
public:

    int attrPos; // A handle for the "in" vec4 representing vertex position in the vertex shader
    int attrNor; // A handle for the "in" vec4 representing vertex normal in the vertex shader
    int attrUV; // A handle for the "in" vec2 representing the UV coordinates in the vertex shader


public:
    SurfaceShader(OpenGLContext* context);
    virtual ~SurfaceShader();

    // Sets up shader-specific handles
    virtual void setupMemberVars() override;
    // Draw the given object to our screen using this ShaderProgram's shaders
    virtual void draw(Drawable &d, int textureSlot) override;


};
