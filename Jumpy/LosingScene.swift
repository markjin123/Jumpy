//
//  LosingScene.swift
//  Jumpy
//
//  Created by Mark Jin on 3/21/16.
//  Copyright © 2016 Mark Jin. All rights reserved.
//

import Foundation
import SpriteKit

class LosingScene: SKScene {
    let loseText = SKLabelNode(fontNamed: "AppleColorEmoji")
    let scoreText = SKLabelNode(fontNamed: "AppleColorEmoji")
    let restart = SKLabelNode(fontNamed: "AppleColorEmoji")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        print(score)
        
        //sets up the you lose text
        loseText.text = "You Lose"
        loseText.position = CGPointMake(self.size.width/2, self.size.height/2)
        loseText.fontSize = 30
        loseText.color = SKColor.whiteColor()
        loseText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        //sets up the end game score text
        scoreText.text = "Score: \(score)"
        scoreText.position = CGPointMake(self.size.width/2, self.size.height/3)
        scoreText.color = SKColor.whiteColor()
        scoreText.fontSize = 20
        scoreText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        //sets up the restart text with the a repeated fadein and fadeout animation
        let fadeIn = SKAction.fadeAlphaTo(0.25, duration: 0.5)
        let fadeOut = SKAction.fadeAlphaTo(1, duration: 0.5)
        let sequenceRestart = SKAction.sequence([fadeIn,fadeOut])
        
        //sets up the restart text
        restart.text = "Tap Anywhere to Restart"
        restart.position = CGPointMake(self.size.width/2, self.size.height/4)
        restart.color = SKColor.whiteColor()
        restart.fontSize = 15
        restart.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        restart.runAction(SKAction.repeatActionForever(sequenceRestart))
        
        addChild(restart)
        addChild(loseText)
        addChild(scoreText)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let transition = SKTransition.crossFadeWithDuration(1.0)
        let renew = GameScene(size: size)
        
        view?.presentScene(renew, transition: transition)
    }
    
}
