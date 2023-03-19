//
//  GameBridge.h
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#ifndef GameBridge_h
#define GameBridge_h

#import <GLKit/GLKit.h>

struct Game;

#ifdef __cplusplus
extern "C"
{
#endif
//Creates a game and gives Swift the pointer to it for future calls.
struct Game* NewGame(GLKView* view);
//Game's update function to be triggered by the update.
void GameUpdate(struct Game* inThis);
//Game's draw that passes things to the renderer draw.
void GameDraw(struct Game* inThis, CGRect rect);
//Game Event caller.
void GameEventSinglePan(struct Game* inThis, GLKVector2 input);
void GameEventDoublePan(struct Game* inThis, GLKVector2 input);
void GameEventPinch(struct Game* inThis, float input);
void GameEventDoubleTap(struct Game* inThis);
void ToggleDayNight(struct Game* inThis);
void ToggleFlashlight(struct Game* inThis);
void ToggleFog(struct Game* inThis);
void ChangeFogDensity(struct Game* inThis, float changeBy);
void NextFogMode(struct Game* inThis);
void ChangeFogStart(struct Game* inThis, float changeBy);
void ChangeFogEnd(struct Game* inThis, float changeBy);
#ifdef __cplusplus
}
#endif

#endif /* GameBridge_h */
