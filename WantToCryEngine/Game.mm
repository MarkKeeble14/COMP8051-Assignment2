//
//  Game.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "Game.hpp"

Game::Game(GLKView* view){
    //basic setup
    NSBundle* bundleName = [NSBundle mainBundle];
    NSString* nspath = [bundleName bundlePath];
    NSString* nspathAppended = [nspath stringByAppendingString: @"/"];

    resourcePath = std::string();
    resourcePath = nspathAppended.UTF8String;

    models = std::map<std::string, GeometryObject>();
    objects = std::map<std::string, GameObject>();
    textures = std::map<std::string, GLuint>();
    
    //renderer setup
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
    CGImageRef img3 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"crate.jpg"]].CGImage;
    textures["crate"] = renderer.loadTexture(img3);
    CGImageRef img4 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"newWall.jpeg"]].CGImage;
    textures["wall"] = renderer.loadTexture(img4);
    
    //Load models
//    models["helmet"] = WavefrontLoader::ReadFile(resourcePath + "halo_reach_grenadier.obj");
    models["monkey"] = WavefrontLoader::ReadFile(resourcePath + "blender_suzanne.obj");
    models["cube"] = WavefrontLoader::ReadFile(resourcePath + "cube.obj");
    models["maze"] = WavefrontLoader::ReadFile(resourcePath + "maze.obj");
    //load models into reusable VAOs
    for(auto i : models){
        loadedGeometry[i.first] = PreloadedGeometryObject(renderer.loadGeometryVAO(i.second), models[i.first].GetRadius(), models[i.first].indices);
    }
    
    //Create game objects
    /*
    objects["static"] = GameObject(GLKVector3{0, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static"].preloadedGeometry = loadedGeometry["cube"];
    objects["static"].textureIndex = textures["test"];
     */
    
    /*
    for(int i = 0; i <= 100; i++){
        std::string wb = std::string("wallblock").append(std::to_string(i));
        objects[wb] = GameObject(GLKVector3{2, -1, -50.0f + i}, GLKVector3{0, 0, 0}, GLKVector3{1, 2, 1});
        objects[wb].preloadedGeometry = loadedGeometry["cube"];
        objects[wb].textureIndex = textures["tile"];
    }
     */
    
    /*
    objects["bottom"] = GameObject(GLKVector3{0, -5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["bottom"].preloadedGeometry = loadedGeometry["monkey"];
    objects["bottom"].color = GLKVector4{0, 0, .25, 1};
    objects["bottom"].textureIndex = textures[""];

    objects["top"] = GameObject(GLKVector3{0, 5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["top"].preloadedGeometry = loadedGeometry["monkey"];
    objects["top"].color = GLKVector4{.5, .5, 0, 1};
    objects["top"].textureIndex = textures[""];

    objects["left"] = GameObject(GLKVector3{-5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["left"].preloadedGeometry = loadedGeometry["monkey"];
    objects["left"].color = GLKVector4{1, 0, 0, 1};
    objects["left"].textureIndex = textures[""];

    objects["far"] = GameObject(GLKVector3{-15, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["far"].preloadedGeometry = loadedGeometry["monkey"];
    objects["far"].color = GLKVector4{1, 0, 0, 1};
    objects["far"].textureIndex = textures[""];
    
    objects["right"] = GameObject(GLKVector3{5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["right"].preloadedGeometry = loadedGeometry["monkey"];
    objects["right"].color = GLKVector4{0, 1, 0, 1};
    objects["right"].textureIndex = textures["tile"];

    objects["back"] = GameObject(GLKVector3{0, 0, 5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["back"].preloadedGeometry = loadedGeometry["monkey"];
    objects["back"].color = GLKVector4{.5, 0, .5, 1};
    objects["back"].textureIndex = textures["tile"];
    */
    
    /*
    objects["victim"] =  GameObject(GLKVector3{0, 1, -5}, GLKVector3{0, 4.712, 0}, GLKVector3{1, 1, 1});
    objects["victim"].preloadedGeometry = loadedGeometry["monkey"];
    objects["victim"].color = GLKVector4{0, 0.25, .5, 1};
    objects["victim"].textureIndex = textures[""];
    */
    
    objects["crate"] = GameObject(GLKVector3{0, 0, -2}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["crate"].preloadedGeometry = loadedGeometry["cube"];
    objects["crate"].textureIndex = textures["crate"];
    
    objects["maze"] = GameObject(GLKVector3{-6, -1, -11}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["maze"].preloadedGeometry = loadedGeometry["maze"];
    objects["maze"].textureIndex = textures["wall"];
}

//It seems like the renderer needs to have cycled once for some things to work.
//This might just be the least janky way of going about it.
void Game::FirstUpdate(){
    fogActive = true;
    renderer.setEnvironment(15, 40, GLKVector4{0.65, 0.7, 0.75, 1});
    ToggleDayNight();
    
    Light l = Light();
    
    l.type = 0;
    l.color = GLKVector3{1, 1, 1};
    l.direction = GLKVector3{0.2, -1, -0.5};
    l.power = 1;
    
    renderer.setLight(0, l);
    
    l.type = 0;
    l.color = GLKVector3{1, 0, 0};
    l.direction = GLKVector3{-0.5, 0, -0.5};
    l.power = 0.25;
    
    renderer.setLight(1, l);
    
}

void Game::Update(){
    //Deal with FirstUpdate
    if(!firstUpdated){
        FirstUpdate();
        firstUpdated = true;
    }
    
    // rotate the crate
    objects["crate"].transform.rotation =
    GLKVector3Add(objects["crate"].transform.rotation, GLKVector3{0.0, 0.01, 0.0});
    
    //Per-frame events - here, a spotlight attached to the camera has its position changed.
    Light l = Light();
    
    l.type = 2;
    l.color = GLKVector3{0.2, 0.2, 1};
    l.direction = rotToDir(renderer.camRot);
    l.position = renderer.camPos;
    if (flashlightEnabled) {
        l.power = 1;
    } else {
        l.power = 0;
    }
    l.attenuationZeroDistance = 15;
    l.distanceLimit = 10;
    l.angle = 0.25;
    
    renderer.setLight(1, l);

    renderer.update();
}

void Game::ToggleFlashlight() {
    flashlightEnabled = !flashlightEnabled;
}

void Game::ToggleDayNight() {
    isNight = !isNight;
    if (isNight) {
        renderer.setAmbientLight(0.0);
    } else {
        renderer.setAmbientLight(1.0);
    }
}

void Game::ToggleFog() {
    fogActive = !fogActive;
    renderer.setFogEnabled(fogActive);
}

void Game::NextFogMode() {
    fogMode += 1;
    if (fogMode > 2) {
        fogMode = 0;
    }
    renderer.setFogMode(fogMode);
}

void Game::ChangeFogDensity(float changeBy) {
    fogDensity = changeBy;
    renderer.setFogDensity(fogDensity);
}

void Game::ChangeFogEnd(float changeBy) {
    fogEnd = changeBy;
    renderer.setFogEnd(fogEnd);
}

void Game::ChangeFogStart(float changeBy) {
    fogStart = changeBy;
    renderer.setFogStart(fogStart);
}

void Game::DrawCall(CGRect* drawArea){
    //Issue draw calls for each of the game objects to the renderer.
    for(auto i : objects){
        if(i.second.preloadedGeometry.vao){
            renderer.drawVAO(i.second.preloadedGeometry.vao,
                             i.second.preloadedGeometry.indices,
                             i.second.preloadedGeometry.radius,
                             i.second.transform.position, i.second.transform.rotation,
                             i.second.transform.scale, i.second.textureIndex,
                             i.second.color, drawArea);
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
    renderer.camPos.x -= cos(renderer.camRot.y) * input.x;
    renderer.camPos.z += sin(renderer.camRot.y) * input.x;
    renderer.camPos.y += input.y;
}

void Game::EventPinch(float input){
    renderer.camPos.z += cos(renderer.camRot.y) * input;
    renderer.camPos.x += sin(renderer.camRot.y) * input;
}

void Game::EventDoubleTap(){
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};

    if(fogActive){
        renderer.setEnvironment(100, 40, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = false;
    } else {
        renderer.setEnvironment(15, 40, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = true;
    }
}
