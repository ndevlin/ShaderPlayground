// Created by Adam Mally, modified by Nathan Devlin

#include "postprocessshader.h"
#include <QDateTime>

PostProcessShader::PostProcessShader(OpenGLContext *context)
    : ShaderProgram(context),
      attrPos(-1), attrUV(-1),
      unifDimensions(-1)
{}

PostProcessShader::~PostProcessShader()
{}

void PostProcessShader::setupMemberVars()
{
    attrPos = context->glGetAttribLocation(prog, "vs_Pos");

    attrUV  = context->glGetAttribLocation(prog, "vs_UV");

    unifTime = context->glGetUniformLocation(prog, "u_Time");

    unifSampler2D = context->glGetUniformLocation(prog, "u_RenderedTexture");

    unifDimensions = context->glGetUniformLocation(prog, "u_Dimensions");

    unifSampler2D_DepthText = context->glGetUniformLocation(prog, "u_DepthTexture");

    unifView = context->glGetUniformLocation(prog, "u_View");

    unifProj = context->glGetUniformLocation(prog, "u_Proj");

    unifProjInv = context->glGetUniformLocation(prog, "u_ProjInv");


    attrCamPos = context->glGetUniformLocation(prog, "u_CameraPos");
    setGPUCamPos(attrCamPos, glm::vec4(0.f, 0.f, 12.f, 1.f)); // Set initial position

    unifInverseViewMat = context->glGetUniformLocation(prog, "u_InverseViewMat");

    unifCurrentToPrevMat = context->glGetUniformLocation(prog, "u_CurrentToPrevMat");

}

void PostProcessShader::draw(Drawable& d, int textureSlot = 0)
{
    useMe();

    // Set our "renderedTexture" sampler to user Texture Unit 0
    context->glUniform1i(unifSampler2D, textureSlot);

    // Set our "depthTexture" sampler to user Texture Unit 1
    context->glUniform1i(unifSampler2D_DepthText, textureSlot + 1);

    // Each of the following blocks checks that:
    //   * This shader has this attribute, and
    //   * This Drawable has a vertex buffer for this attribute.
    // If so, it binds the appropriate buffers to each attribute.

    if (attrPos != -1 && d.bindPos()) {
        context->glEnableVertexAttribArray(attrPos);
        context->glVertexAttribPointer(attrPos, 4, GL_FLOAT, false, 0, NULL);
    }
    if (attrUV != -1 && d.bindUV()) {
        context->glEnableVertexAttribArray(attrUV);
        context->glVertexAttribPointer(attrUV, 2, GL_FLOAT, false, 0, NULL);
    }

    // Bind the index buffer and then draw shapes from it.
    // This invokes the shader program, which accesses the vertex buffers.
    d.bindIdx();
    context->glDrawElements(d.drawMode(), d.elemCount(), GL_UNSIGNED_INT, 0);

    if (attrPos != -1) context->glDisableVertexAttribArray(attrPos);
    if (attrUV != -1) context->glDisableVertexAttribArray(attrUV);

    context->printGLErrorLog();
}


void PostProcessShader::setDimensions(glm::ivec2 dims)
{
    useMe();

    if(unifDimensions != -1)
    {
        context->glUniform2i(unifDimensions, dims.x, dims.y);
    }
}
