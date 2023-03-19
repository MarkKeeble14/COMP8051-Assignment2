//
//  GameBridge.c
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "GameBridge.h"
#include "Game.hpp"

extern "C" Game* NewGame(GLKView* view){
    return new Game(view);
}

extern "C" void GameUpdate(struct Game* inThis){
    inThis->Update();
}

extern "C" void GameDraw(struct Game* inThis, CGRect rect){
    inThis->DrawCall(&rect);
}

extern "C" void GameEventSinglePan(struct Game* inThis, GLKVector2 input){
    inThis->EventSinglePan(input);
}

extern "C" void GameEventDoublePan(struct Game* inThis, GLKVector2 input){
    inThis->EventDoublePan(input);
}

extern "C" void GameEventPinch(struct Game* inThis, float input){
    inThis->EventPinch(input);
}

extern "C" void GameEventDoubleTap(struct Game* inThis){
    inThis->EventDoubleTap();
}

extern "C" void ToggleDayNight(struct Game* inThis) {
    inThis->ToggleDayNight();
}

extern "C" void ToggleFlashlight(struct Game* inThis) {
    inThis->ToggleFlashlight();
}

extern "C" void ToggleFog(struct Game* inThis) {
    inThis->ToggleFog();
}

extern "C" void NextFogMode(struct Game* inThis) {
    inThis->NextFogMode();
}

extern "C" void ChangeFogDensity(struct Game* inThis, float changeBy) {
    inThis->ChangeFogDensity(changeBy);
}

extern "C" void ChangeFogEnd(struct Game* inThis, float changeBy) {
    inThis->ChangeFogEnd(changeBy);
}

extern "C" void ChangeFogStart(struct Game* inThis, float changeBy) {
    inThis->ChangeFogStart(changeBy);
}
