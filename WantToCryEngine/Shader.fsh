#version 300 es

precision highp float;


struct Light{
    //0 for directional, 1 for spot, 2 for point
    int type;
    
    vec3 position;
    vec3 direction;
    
    vec3 color;
    float power;
    //spotlight angle in radians.
    float angle;
    //set to negative to make it unlimited.
    float distanceLimit;
    //attenuation is linear for now. Set to negative to disable.
    float attenuationZeroDistance;
};

in vec4 v_color;
in vec3 v_normal;
in vec3 v_pos;
in vec2 v_texCoord;
in float v_dist;
out vec4 o_fragColor;

uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;

//light inputs
#define NUM_LIGHTS 2
uniform Light lights[NUM_LIGHTS];
uniform float ambientLight;

//camera info
uniform vec4 cameraFacing;
uniform vec4 cameraPos;

//texture sampler - only color for now
uniform sampler2D tex;

//fog stuff
uniform bool fogActive;
uniform int fogMode;
uniform float fogDensity;
uniform float fogStart;
uniform float fogFull;
uniform vec4 fogColor;

vec3 SimpleDiffuse(vec3 lightColor, vec3 lightDir){
    return max(dot(v_normal, lightDir), 0.0f) * lightColor ;
}

vec3 SimpleToon(vec3 lightColor, vec3 lightDir){
    vec3 result = dot(v_normal, lightDir) * lightColor;
    float rn = length(result);
    if(rn  < 0.3){
        result = normalize(result) * 0.2;
    } else if(rn  < 0.7){
        result = normalize(result) * 0.5;
    } else if(rn  < 0.95){
        result = normalize(result) * 0.9;
    } else {
        result = vec3(1, 1, 1);
    }
    return result;
}

vec3 Specular(float specularPower, vec3 lightColor, vec3 lightDir){
    float shn = 2.0f;
    
    vec3 viewDir = normalize(cameraPos.xyz - v_pos);
    vec3 reflectionDir = reflect(-lightDir, v_normal);
    
    return pow(max(0.0f, dot(v_normal, reflectionDir)), shn)  * lightColor * specularPower;
}

vec3 SpecularDiffuse(float specularPower, vec3 lightColor, vec3 lightDir){
    return  Specular(specularPower, lightColor, lightDir) + SimpleDiffuse(lightColor, lightDir);
}

vec3 LightFromSource(Light light){
    if(length(light.color) == 0.0f){
        return vec3(0, 0, 0);
    }
    float specPower = 1.0f;
    if(light.type == 0){ //directional light
        if(length(light.direction) == 0.0f){
            return vec3(0, 0, 0);
        }
        vec3 lightDir = normalize(-light.direction);
        return SpecularDiffuse(specPower, light.color, lightDir) * light.power;
    } else if(light.type == 1){ //point light
        float dist = length(light.position - v_pos);
        if((light.distanceLimit >= 0.0f && dist > light.distanceLimit) || (light.attenuationZeroDistance >= 0.0f && dist >= light.attenuationZeroDistance)){
            return vec3(0, 0, 0);
        }
        vec3 lightDir = normalize(light.position - v_pos);
        vec3 result = SpecularDiffuse(specPower, light.color, lightDir);
        if(light.attenuationZeroDistance > 0.0f){
            result *= 1.0f - dist/light.attenuationZeroDistance;
        }
        return result * light.power;
    } else if(light.type == 2){ //spot light
        float dist = length(light.position - v_pos);
        if(length(light.direction) == 0.0f ||
           (light.distanceLimit >= 0.0f && dist > light.distanceLimit) ||
           (light.attenuationZeroDistance >= 0.0f && dist >= light.attenuationZeroDistance) ||
           light.angle <= 0.0f){
            return vec3(0, 0, 0);
        }
        vec3 lightDir = normalize(light.position - v_pos);
        if(acos(dot(lightDir, light.direction)) > light.angle){
            return vec3(0, 0, 0);
        }
        vec3 result = SpecularDiffuse(specPower, light.color, lightDir);
        if(light.attenuationZeroDistance > 0.0f){
            result *= 1.0f - dist/light.attenuationZeroDistance;
        }
        return result * light.power;
    } else {
        return vec3(0, 0, 0);
    }
}

//Equation is same as the linear fog from normal, non-ES OpenGL.
float FogPowerLinear(){
    return clamp((fogFull - v_dist)/(fogFull - fogStart), 0.0, 1.0);
}

float FogPowerExponential() {
    return clamp((1.0 / pow(2.0, v_dist * fogDensity)), 0.0, 1.0);
}

float FogPowerDoubleExponential() {
    return clamp((1.0 / pow(2.0, pow(v_dist * fogDensity, 2.0))), 0.0, 1.0);
}

void main()
{
    vec4 lightingResult = vec4(ambientLight, ambientLight, ambientLight, 1);
    
    for(int i = 0; i < NUM_LIGHTS; i++){
        lightingResult.xyz += LightFromSource(lights[i]);
    }
    
    if(fogActive){
        float fogPower;
        switch (fogMode) {
            case 0:
                fogPower = FogPowerLinear();
                break;
            case 1:
                fogPower = FogPowerExponential();
            case 2:
                fogPower = FogPowerDoubleExponential();
                break;
        }
        
        
        o_fragColor = (texture(tex, v_texCoord) * v_color * lightingResult) * fogPower + fogColor * (1.0 - fogPower);
    } else {
        o_fragColor = texture(tex, v_texCoord) * v_color * lightingResult;
    }
}
