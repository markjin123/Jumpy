//
//  Menu.swift
//  Jumpy
//
//  Created by Mark Jin on 3/21/16.
//  Copyright © 2016 Mark Jin. All rights reserved.
//

import Foundation
import SpriteKit


class Menu: SKScene {
    let start = SKLabelNode(fontNamed: "AppleColorEmoji")
    var logo = SKSpriteNode(imageNamed: "logo")
    var instruction = SKLabelNode(fontNamed: "AppleColorEmoji")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.29, green: 0.02, blue: 0.56, alpha: 1.0)
        
        start.text = "Start"
        start.fontSize = 40
        start.color = SKColor.whiteColor()
        start.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        start.position = CGPointMake(size.width/2, size.height/3)
        
        
        logo.position = CGPointMake(2*size.width/3 - 61.5,2*size.height/3)
        logo.physicsBody?.affectedByGravity = false
        logo.physicsBody?.dynamic = false
        
        addChild(start)
        addChild(logo)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            
            if start.containsPoint(location){
                let transition = SKTransition.crossFadeWithDuration(1.0)
                let renew = GameScene(size: size)
                
                view?.presentScene(renew, transition: transition)
            }
        }
    }
}
