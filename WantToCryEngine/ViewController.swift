//
//  ViewController.swift
//  WantToCryEngine
//
//  Created by Alex on 2023-02-10.
//

import GLKit

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        GameUpdate(game);
    }
}

class ViewController: GLKViewController {
    
    private var context: EAGLContext?;
    private var game: OpaquePointer!;
    
    private var fogModeTracker: Int?;
    private var fogModeText: UITextField?;
    
    private func setup(){
        context = EAGLContext(api: .openGLES3);
        EAGLContext.setCurrent(context);
        if let view = self.view as? GLKView, let context = context {
            view.context = context;
            delegate = self as GLKViewControllerDelegate;
            
            //initialize game (with its renderer)
            game = NewGame(view);
        }

    }
    
    private func setFogModeText() {
        if (fogModeTracker! > 2) {
            fogModeTracker = 0;
        }
        var stringFogMode = "";
        switch (fogModeTracker) {
        case 0:
            stringFogMode = "Linear";
            break;
        case 1:
            stringFogMode = "Exponential";
            break;
        case 2:
            stringFogMode = "Double Exponential";
            break;
        default:
            break;
        }
        fogModeText?.text = stringFogMode;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        setup();
        
        //Gesture recognizer to send input through to the Game.
        let drag = UIPanGestureRecognizer(target: self, action: #selector(self.doDrag(_:)))
        drag.minimumNumberOfTouches = 1;
        drag.maximumNumberOfTouches = 1;
        view.addGestureRecognizer(drag);

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.doPinch(_:)))
        view.addGestureRecognizer(pinch);
        
        let doubleDrag = UIPanGestureRecognizer(target: self, action: #selector(self.doDoubleDrag(_:)))
        doubleDrag.minimumNumberOfTouches = 2;
        doubleDrag.maximumNumberOfTouches = 2;
        view.addGestureRecognizer(doubleDrag);
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doDoubleTap(_:)));
        doubleTap.numberOfTapsRequired = 2;
        view.addGestureRecognizer(doubleTap);

        // Toggle Flashlight
        let toggleLightButton = UIButton();
        toggleLightButton.setTitle("Toggle Flashlight", for: UIControl.State.normal);
        toggleLightButton.frame = CGRect(x: 50, y: view.frame.height - 150, width: 150, height: 50);
        toggleLightButton
            .backgroundColor = UIColor.green;
        toggleLightButton.addTarget(self, action: #selector(self.toggleFlashlight), for: .touchUpInside);
        view.addSubview(toggleLightButton);
        
        // Toggle Day/Night
        let toggleDayNightButton = UIButton();
        toggleDayNightButton.setTitle("Toggle Day/Night", for: UIControl.State.normal);
        toggleDayNightButton.frame = CGRect(x: 50, y: view.frame.height - 100, width: 150, height: 50);
        toggleDayNightButton
            .backgroundColor = UIColor.red;
        toggleDayNightButton.addTarget(self, action: #selector(self.toggleDayNight), for: .touchUpInside);
        view.addSubview(toggleDayNightButton);
        
        // Toggle Fog
        let toggleFogButton = UIButton();
        toggleFogButton.setTitle("Toggle Fog", for: UIControl.State.normal);
        toggleFogButton.frame = CGRect(x: 50, y: view.frame.height - 200, width: 150, height: 50);
        toggleFogButton
            .backgroundColor = UIColor.blue;
        toggleFogButton.addTarget(self, action: #selector(self.toggleFog), for: .touchUpInside);
        view.addSubview(toggleFogButton);
        
        // Fog Density
        let fogDensityTextField = UITextField();
        fogDensityTextField.frame = CGRect(x: 50, y: view.frame.height - 300, width: 150, height: 50);
        fogDensityTextField.addTarget(self, action: #selector(self.setFogDensity), for: UIControl.Event.editingChanged);
        fogDensityTextField.placeholder = "Fog Density";
        view.addSubview(fogDensityTextField);
        
        // Fog Start
        let fogStartTextField = UITextField();
        fogStartTextField.frame = CGRect(x: 50, y: view.frame.height - 350, width: 150, height: 50);
        fogStartTextField.addTarget(self, action: #selector(self.setFogStart), for: UIControl.Event.editingChanged);
        fogStartTextField.placeholder = "Fog Start";
        view.addSubview(fogStartTextField);
        
        // Fog End
        let fogEndTextField = UITextField();
        fogEndTextField.frame = CGRect(x: 50, y: view.frame.height - 400, width: 150, height: 50);
        fogEndTextField.addTarget(self, action: #selector(self.setFogEnd), for: UIControl.Event.editingChanged);
        fogEndTextField.placeholder = "Fog End";
        view.addSubview(fogEndTextField);
        
        // Fog Mode
        // Up
        let cycleFogModeButton = UIButton();
        cycleFogModeButton.setTitle("Cycle Fog Mode", for: UIControl.State.normal);
        cycleFogModeButton.frame = CGRect(x: 50, y: view.frame.height - 250, width: 150, height: 50);
        cycleFogModeButton
            .backgroundColor = UIColor.cyan;
        cycleFogModeButton.addTarget(self, action: #selector(self.cycleFogMode), for: .touchUpInside);
        view.addSubview(cycleFogModeButton);
        
        fogModeText = UITextField();
        fogModeText?.frame = CGRect(x: 200, y: view.frame.height - 100, width: 150, height: 50);
        fogModeText?.isUserInteractionEnabled = false;
        fogModeText?.textColor = UIColor.black;
        fogModeText?.backgroundColor = UIColor.orange;
        fogModeText?.textAlignment = NSTextAlignment.center;
        view.addSubview(fogModeText!);
        fogModeTracker = 0;
        setFogModeText();
    }
    
    @objc func cycleFogMode(_sender: UIButton) {
        NextFogMode(game);
        fogModeTracker! += 1;
        setFogModeText();
    }
    
    @objc func setFogDensity(_sender: UITextField) {
        if let input = Float(_sender.text!) {
            ChangeFogDensity(game, input);
        }
    }
    
    @objc func setFogStart(_sender: UITextField) {
        if let input = Float(_sender.text!) {
            ChangeFogStart(game, input);
        }
    }
    
    @objc func setFogEnd(_sender: UITextField) {
        if let input = Float(_sender.text!) {
            ChangeFogEnd(game, input);
        }
    }
    
    @objc func toggleFog(_sender: UIButton) {
        ToggleFog(game);
    }
    
    @objc func toggleFlashlight(_sender: UIButton) {
        ToggleFlashlight(game);
    }
    
    @objc func toggleDayNight(_sender: UIButton) {
        ToggleDayNight(game);
    }
    
    @objc func doDrag(_ sender: UIPanGestureRecognizer){
        let rot = GLKVector2Make(Float(sender.velocity(in: view).y/2000), Float(sender.velocity(in: view).x/2000));
        //Call relevant game event.
        GameEventSinglePan(game, rot);
    }

    @objc func doDoubleDrag(_ sender: UIPanGestureRecognizer){
        let trans = GLKVector2Make(Float(sender.velocity(in: view).x/2000), Float(sender.velocity(in: view).y/2000));
        //Call relevant game event.
        GameEventDoublePan(game, trans);
    }

    @objc func doPinch(_ sender: UIPinchGestureRecognizer){
        GameEventPinch(game, Float(sender.velocity/10));
    }
    
    @objc func doDoubleTap(_ sender: UITapGestureRecognizer){
        GameEventDoubleTap(game);
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        GameDraw(game, rect);
    }

}

