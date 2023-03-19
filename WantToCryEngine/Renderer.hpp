//
//  Renderer.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-11.
//

#ifndef Renderer_hpp
#define Renderer_hpp

#include <GLKit/GLKit.h>
#include <OpenGLES/ES3/gl.h>

#include "Common.h"
#include <vector>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <map>
#include "WavefrontLoader.hpp"

//This needs to be a constant because GLSL can't handle variable loops
#define NUM_LIGHTS 2

//Frustrum check values. Styled after what I presume GLKit does.
#define FRUSTRUM_OBJECT_OUT 0
#define FRUSTRUM_OBJECT_RADIUS 1
#define FRUSTRUM_OBJECT_ORIGIN 2

struct Light{
    //0 for directional, 1 for spot, 2 for point
    GLint type;
    
    GLKVector3 position;
    GLKVector3 direction;
    
    GLKVector3 color;
    float power;
    //spotlight angle in radians.
    float angle;
    //set to negative to make it unlimited.
    float distanceLimit;
    //attenuation is linear for now. Set to negative to disable.
    float attenuationZeroDistance;
};

class Renderer{
private:
    char* readShaderSource(const std::string& path);
    GLuint loadShader(GLenum shaderType, char* shaderSource);
    GLuint loadGLProgram(char* vertexShaderSource, char* fragShaderSource);
    //returns FRUSTRUM_OBJECT_OUT if not visible, FRUSTRUM_OBJECT_RADIUS if radius visible, FRUSTRUM_OBJECT_ORIGIN if origin visible.
    GLuint ConeCheck(float radius, const GLKVector3& objPos,
                         float halfFOV);    
    std::string resourcePath;
    GLKView* targetView;
    GLuint programObject;
    GLuint nextTexture;
    GLKMatrix4 perspective;
    GLKMatrix4 view;
    float* posBuffer;
    float* normBuffer;
    float* texCoordBuffer;
    int* indexBuffer;
    Light lights[NUM_LIGHTS];
public:
    Renderer();
    ~Renderer();
    void setup(GLKView* view);
    void update();
    void drawModel(const std::string& refName, const GLKVector3& pos,
                   const GLKVector3& rot, CGRect* drawArea);
    /*
    void drawGeometryObject(const GeometryObject& object,
                            const GLKVector3& pos, const GLKVector3& rot,
                            const GLKVector3& scale, GLuint textureIndex,
                            const GLKVector4& color, CGRect* drawArea);
     */
    void drawVAO(GLuint vao, const std::vector<int>& indeces, float radius,
                 const GLKVector3& pos, const GLKVector3& rot,
                 const GLKVector3& scale, GLuint textureIndex,
                 const GLKVector4& color, CGRect* drawArea);
    GLuint loadTexture(CGImageRef img);
    GLuint loadGeometryVAO(const GeometryObject& geo);
    GLKMatrix4 getViewMatrix();
    void setEnvironment(float fogStartDist, float fogFullDist, const GLKVector4& color);
    GLKVector3 camPos;
    GLKVector3 camRot;
    void setLight(GLuint i, Light light);
    void setAmbientLight(float power);
    void setFogEnabled(bool fogEnabled);
    void setFogMode(int fogMode);
    void setFogDensity(float fogDensity);
    void setFogStart(float fogStart);
    void setFogEnd(float fogEnd);
};

#endif /* Renderer_hpp */
