#include "surfaceshader.h"


SurfaceShader::SurfaceShader(OpenGLContext *context)
    : ShaderProgram(context),
      attrPos(-1), attrNor(-1), attrUV(-1)
{}

SurfaceShader::~SurfaceShader()
{}

void SurfaceShader::setupMemberVars()
{
    attrPos = context->glGetAttribLocation(prog, "vs_Pos");
    attrNor = context->glGetAttribLocation(prog, "vs_Nor");
    attrUV  = context->glGetAttribLocation(prog, "vs_UV");
    unifModel      = context->glGetUniformLocation(prog, "u_Model");
    unifModelInvTr = context->glGetUniformLocation(prog, "u_ModelInvTr");
    unifView       = context->glGetUniformLocation(prog, "u_View");
    unifProj       = context->glGetUniformLocation(prog, "u_Proj");

    unifSampler2D  = context->glGetUniformLocation(prog, "u_Texture");
    unifTime = context->glGetUniformLocation(prog, "u_Time");


    // Added handle setup
    attrCamPos = context->glGetUniformLocation(prog, "u_CameraPos");
    setGPUCamPos(attrCamPos, glm::vec4(0.f, 0.f, 12.f, 1.f)); // Set initial position


    context->printGLErrorLog();
}





//This function, as its name implies, uses the passed in GL widget
void SurfaceShader::draw(Drawable &d, int textureSlot = 0)
{
    useMe();

    if(unifSampler2D != -1)
    {
        context->glUniform1i(unifSampler2D, /*GL_TEXTURE*/textureSlot);
    }

    // Each of the following blocks checks that:
    //   * This shader has this attribute, and
    //   * This Drawable has a vertex buffer for this attribute.
    // If so, it binds the appropriate buffers to each attribute.

    if (attrPos != -1 && d.bindPos()) {
        context->glEnableVertexAttribArray(attrPos);
        context->glVertexAttribPointer(attrPos, 4, GL_FLOAT, false, 0, NULL);
    }

    if (attrNor != -1 && d.bindNor()) {
        context->glEnableVertexAttribArray(attrNor);
        context->glVertexAttribPointer(attrNor, 4, GL_FLOAT, false, 0, NULL);
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
    if (attrNor != -1) context->glDisableVertexAttribArray(attrNor);
    if (attrUV != -1) context->glDisableVertexAttribArray(attrUV);

    context->printGLErrorLog();
}


