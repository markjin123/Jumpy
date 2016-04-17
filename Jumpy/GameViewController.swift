//
//  GameViewController.swift
//  Jumpy
//
//  Created by Mark Jin on 3/21/16.
//  Copyright (c) 2016 Mark Jin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var scene: Menu!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad(){
        let skView  = view as! SKView
        scene = Menu(size:skView.bounds.size)
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
    }
}

