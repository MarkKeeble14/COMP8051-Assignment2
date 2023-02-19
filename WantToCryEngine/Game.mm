//
//  Game.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "Game.hpp"

Game::Game(GLKView* view){
    NSBundle* bundleName = [NSBundle mainBundle];
    NSString* nspath = [bundleName bundlePath];
    NSString* nspathAppended = [nspath stringByAppendingString: @"/"];

    resourcePath = std::string();
    resourcePath = nspathAppended.UTF8String;

    models = std::map<std::string, GeometryObject>();
    objects = std::map<std::string, GameObject>();
    textures = std::map<std::string, GLuint>();
    
    renderer = Renderer();
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};
    renderer.setup(view);
    
    //Load in textures.
    CGImageRef img0 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"white.jpg"]].CGImage;
    textures[""] = renderer.loadTexture(img0);
    CGImageRef img1 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"test.jpg"]].CGImage;
    textures["test"] = renderer.loadTexture(img1);
    CGImageRef img2 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"tile.jpg"]].CGImage;
    textures["tile"] = renderer.loadTexture(img2);
    
    
//    models["helmet"] = WavefrontLoader::ReadFile(resourcePath + "halo_reach_grenadier.obj");
    models["monkey"] = WavefrontLoader::ReadFile(resourcePath + "blender_suzanne.obj");
    models["cube"] = WavefrontLoader::ReadFile(resourcePath + "cube.obj");
    
    objects["static"] = GameObject(GLKVector3{0, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static"].geometry = models["cube"];
    objects["static"].textureIndex = textures["test"];
    objects["tilecube"] = GameObject(GLKVector3{2, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["tilecube"].geometry = models["cube"];
    objects["tilecube"].textureIndex = textures["tile"];

    
    objects["bottom"] = GameObject(GLKVector3{0, -5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["bottom"].geometry = models["monkey"];
    objects["bottom"].color = GLKVector4{0, 0, .25, 1};
    objects["bottom"].textureIndex = textures[""];

    objects["top"] = GameObject(GLKVector3{0, 5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["top"].geometry = models["monkey"];
    objects["top"].color = GLKVector4{.5, .5, 0, 1};
    objects["top"].textureIndex = textures[""];

    objects["left"] = GameObject(GLKVector3{-5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["left"].geometry = models["monkey"];
    objects["left"].color = GLKVector4{1, 0, 0, 1};
    objects["left"].textureIndex = textures[""];

    objects["right"] = GameObject(GLKVector3{5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["right"].geometry = models["monkey"];
    objects["right"].color = GLKVector4{0, 1, 0, 1};
    objects["right"].textureIndex = textures["tile"];

    objects["back"] = GameObject(GLKVector3{0, 0, 5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["back"].geometry = models["monkey"];
    objects["back"].color = GLKVector4{.5, 0, .5, 1};
    objects["back"].textureIndex = textures["tile"];

    objects["victim"] =  GameObject(GLKVector3{0, 1, -5}, GLKVector3{0, 4.712, 0}, GLKVector3{1, 1, 1});
    objects["victim"].geometry = models["monkey"];
    objects["victim"].color = GLKVector4{0, 0.25, .5, 1};
    objects["victim"].textureIndex = textures[""];

}

void Game::Update(){
    renderer.update();
}

void Game::DrawCall(CGRect* drawArea){
    for(auto i : objects){
        if(i.second.geometry.indices.size() > 3){
            renderer.drawGeometryObject(i.second.geometry, i.second.transform.position, i.second.transform.rotation, i.second.transform.scale, i.second.textureIndex, i.second.color, drawArea);
        }
    }
}

void Game::EventSinglePan(GLKVector2 input){
    /*
    objects["victim"].transform.rotation.x += input.x;
    objects["victim"].transform.rotation.y += input.y;
     */
    renderer.camRot.y -= input.y;
    renderer.camRot.x -= input.x;
}

void Game::EventDoublePan(GLKVector2 input){
    renderer.camPos.x += cos(renderer.camRot.y) * input.x;
    renderer.camPos.z -= sin(renderer.camRot.y) * input.x;
    renderer.camPos.y -= input.y;
}

void Game::EventPinch(float input){
    renderer.camPos.z -= cos(renderer.camRot.y) * input;
    renderer.camPos.x -= sin(renderer.camRot.y) * input;
}

void Game::EventDoubleTap(){
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};
}
