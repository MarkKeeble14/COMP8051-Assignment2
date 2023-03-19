//
//  Game.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#ifndef Game_hpp
#define Game_hpp

#include <stdio.h>
#include "Common.h"

class Game{
public:
    std::string resourcePath;
    //these are used to store models, texture indices, and gameobjects in an easily accessible way.
    std::map<std::string, GeometryObject> models;
    std::map<std::string, PreloadedGeometryObject> loadedGeometry;
    std::map<std::string, GLuint> textures;
    std::map<std::string, GameObject> objects;
    Renderer renderer;
    //Set up the base state upon construction. Build the level, etc...
    //The view is required to set up the Renderer straight from here.
    Game(GLKView* view);
    //Call these events from Swift using the GameBridge.
    void EventDoubleTap();
    //Events can have parameters - once again, pass in from Swift through GameBridge.
    void EventSinglePan(GLKVector2 input);
    void EventDoublePan(GLKVector2 input);
    void EventPinch(float input);
    //This is where the magic happens - pass the frame update to this function.
    void Update();
    //This is a bridge to the Renderer.
    void DrawCall(CGRect* drawArea);
    void ToggleDayNight();
    void ToggleFlashlight();
    void ToggleFog();
    void ChangeFogDensity(float changeBy);
    void ChangeFogStart(float changeBy);
    void ChangeFogEnd(float changeBy);
    void NextFogMode();
private:
    bool fogActive;
    float fogStart;
    float fogEnd;
    float fogDensity;
    int fogMode;
    bool isNight;
    bool flashlightEnabled;
    bool firstUpdated;
    void FirstUpdate();
};


#endif /* Game_hpp */
