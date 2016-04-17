//
//  GameScene.swift
//  Jumpy
//
//  Created by Mark Jin on 3/21/16.
//  Copyright (c) 2016 Mark Jin. All rights reserved.
//


import SpriteKit
import CoreMotion
import Darwin
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundNode : SKSpriteNode = SKSpriteNode()
    var playerNode : SKSpriteNode = SKSpriteNode()
    var foreground : SKSpriteNode  = SKSpriteNode()
    var impulseCount = 4
    let CollisionCategoryPlayer : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let CollisionCategoryHole : UInt32 = 0x1 << 3
    let CollisionCategoryLine : UInt32 = 0x1 << 4
    let coreMotionManager = CMMotionManager()
    var backgroundMusic = SKAudioNode()
    var score = 0;
    let powerUpHit = SKAction.playSoundFileNamed("135936__bradwesson__collectcoin.wav",
        waitForCompletion: false)
    var firstHit = true;
    var jumps = 0;
    let jumpScoreNode = SKLabelNode(fontNamed: "AppleColorEmoji")
    let startMessageNode = SKLabelNode(fontNamed: "AppleColorEmoji")
    let scoreNode = SKLabelNode(fontNamed: "AppleColorEmoji")
    var volumeOff: SKSpriteNode = SKSpriteNode()
    var volumeOn: SKSpriteNode = SKSpriteNode()
    var sound = true
    
    let UI = UIScreen()
    var xAcc : CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -4.0);
        
        backgroundColor = SKColor(red: 0.55, green: 0.90 , blue: 0.90, alpha: 1.0)
        
        userInteractionEnabled = true
        //add the backgroundmusic
        
        // add the player
        playerNode = SKSpriteNode(imageNamed: "playerGreen")
        
        playerNode.physicsBody =
            SKPhysicsBody(circleOfRadius: playerNode.size.width / 2)
        playerNode.physicsBody!.dynamic = false
        
        playerNode.position = CGPoint(x: size.width / 2.0, y: 80.0)
        playerNode.physicsBody!.linearDamping = 1.0
        playerNode.physicsBody!.allowsRotation = false
        playerNode.physicsBody!.categoryBitMask = CollisionCategoryPlayer
        playerNode.physicsBody!.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryHole
        playerNode.physicsBody!.collisionBitMask = 0
        foreground.addChild(playerNode)
        
        //add the score
        scoreNode.text = "Score: \(score)"
        scoreNode.fontColor = SKColor.blackColor()
        scoreNode.fontSize = 20
        scoreNode.position  = CGPointMake(size.width/2, size.height-20)
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        //add the number of jumps
        jumpScoreNode.text = "Jumps: \(impulseCount)"
        jumpScoreNode.fontSize = 20
        jumpScoreNode.fontColor = SKColor.blackColor()
        jumpScoreNode.position  = CGPointMake(60, 10)
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        //starting message fade
        let fadeIn = SKAction.fadeOutWithDuration(0.5)
        let fadeOut = SKAction.fadeInWithDuration(0.5)
        let sequenceStart = SKAction.sequence([fadeIn,fadeOut])
        let fade = SKAction.repeatActionForever(sequenceStart)
        
        //starting message
        startMessageNode.text = "Touch Anywhere To Start"
        startMessageNode.fontSize = 20
        startMessageNode.fontColor = SKColor.blackColor()
        startMessageNode.position = CGPointMake(self.size.width/2,self.size.height/2)
        startMessageNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        startMessageNode.runAction(fade)
        
        
        //adding the sound icons
        volumeOff = SKSpriteNode(imageNamed: "volumeOff")
        volumeOff.physicsBody?.dynamic = false
        volumeOff.position = CGPoint(x: CGFloat(Double(self.size.width) - 33.3), y: CGFloat(40))
        volumeOn = SKSpriteNode(imageNamed: "volumeOn")
        volumeOn.physicsBody?.dynamic = false
        volumeOn.position = CGPoint(x: CGFloat(Int(self.size.width) - 40), y: CGFloat(40))
        
        
        addHole()
        someLine()
        addPowerUp()
        circleBall()
        addChild(foreground)
        addChild(volumeOn)
        addChild(scoreNode)
        addChild(jumpScoreNode)
        addChild(startMessageNode)
        //adding the background music
        runAction(SKAction.waitForDuration(0.1), completion: {
            self.backgroundMusic = SKAudioNode(fileNamed: "bensound-goinghigher.mp3")
            self.backgroundMusic.autoplayLooped = true
            self.addChild(self.backgroundMusic)
        })
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            if volumeOn.containsPoint(location) && sound{
                backgroundMusic.removeFromParent()
                volumeOn.removeFromParent()
                addChild(volumeOff)
                sound = false
            }
            else if volumeOff.containsPoint(location) && !sound{
                    addChild(backgroundMusic)
                    addChild(volumeOn)
                    volumeOff.removeFromParent()
                    sound = true
            }else{
                if(firstHit){
                    firstHit = false;
                    startMessageNode.removeFromParent()
                }
                if playerNode.physicsBody!.dynamic == false {
                    
                    playerNode.physicsBody!.dynamic = true
                    
                    
                    if coreMotionManager.accelerometerAvailable
                    {
                        coreMotionManager.accelerometerUpdateInterval = 0.2
                        coreMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue())
                            {
                                data, error in
                                self.xAcc = CGFloat(data!.acceleration.x)
                        }
                    }
                }
                if impulseCount > 0 {
                    
                    playerNode.physicsBody!.applyImpulse(CGVectorMake(0.0, 20.0))
                    impulseCount--
                    jumpScoreNode.text = "Jumps: \(impulseCount)"
                }

            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let nodeB = contact.bodyB.node!
        
        if nodeB.name == "powerup" {
            if sound{
                self.runAction(powerUpHit)
            }
            nodeB.removeFromParent()
            impulseCount++
            jumpScoreNode.text = "Jumps: \(impulseCount)"
            score++
            scoreNode.text = "Score: \(score)"
        }
        else if nodeB.name == "hole"{
            playerNode.physicsBody?.contactTestBitMask = 0
            impulseCount = 0
            jumpScoreNode.text = "Jumps: \(impulseCount)"
        }else if nodeB.name == "line"{
            self.playerNode.physicsBody?.velocity = CGVectorMake(0.0, 0.0)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if playerNode.position.y >= 300{
            foreground.position = CGPointMake(self.foreground.position.x, -(self.playerNode.position.y - 300))
        }
        if playerNode.position.y <= 0{
            let transition = SKTransition.crossFadeWithDuration(1.0)
            let losing = LosingScene(size: size, score: score)
            
            view?.presentScene(losing, transition: transition)
        }
        
        if (score > 5 && score < 10){
            backgroundColor = SKColor(red: 0.53, green: 0.63, blue: 0.72, alpha: 1.0);
        }
    }
    
    override func didSimulatePhysics() {
        self.playerNode.physicsBody?.velocity = CGVectorMake(self.xAcc * 380.0, self.playerNode.physicsBody!.velocity.dy)
        
        if playerNode.position.x < -(playerNode.size.width/2){
            playerNode.position = CGPointMake(size.width - playerNode.size.width, playerNode.position.y)
        }else if self.playerNode.position.x > self.size.width{
            playerNode.position  =  CGPointMake(playerNode.size.width/2, playerNode.position.y)
        }
    }
    
    func addHole(){
        let moveLeft =  SKAction.moveToX(0.0, duration: 2.0)
        let moveRight = SKAction.moveToX(self.size.width, duration: 2.0)
        let sequence = SKAction.sequence([moveLeft,moveRight])
        let moveAction = SKAction.repeatActionForever(sequence)
        for i in 1 ... 10{
            let holeNode  = SKSpriteNode(imageNamed: "hole")
            
            holeNode.position = CGPointMake(self.size.width - 100, 600 * CGFloat(i))
            holeNode.physicsBody = SKPhysicsBody(circleOfRadius: holeNode.size.width/2)
            holeNode.physicsBody?.dynamic = false
            holeNode.name = "hole"
            holeNode.physicsBody?.categoryBitMask = CollisionCategoryHole
            holeNode.physicsBody?.collisionBitMask = 0
            
            foreground.addChild(holeNode)
            
            holeNode.runAction(moveAction)
        }
        
    }
    
    func addPowerUp(){
        let Positions: [CGPoint] = [CGPointMake(self.size.width/2, 500),CGPointMake(self.size.width/2, 900),CGPointMake(self.size.width/2, 1000),CGPointMake(self.size.width/2, 1200),CGPointMake(self.size.width/2, 1400),CGPointMake(self.size.width/2, 1600),CGPointMake(self.size.width/2, 1800),CGPointMake(self.size.width/2, 2000),CGPointMake(self.size.width/2, 2200),CGPointMake(self.size.width/2, 2400),CGPointMake(self.size.width/2, 2600),CGPointMake(self.size.width/2, 2800)]
        
        for i in 0 ... 11{
            let powerUP = SKSpriteNode(imageNamed: "powerup")
            powerUP.position = Positions[i]
            powerUP.physicsBody = SKPhysicsBody(circleOfRadius: powerUP.size.width/2)
            powerUP.physicsBody?.dynamic = false
            
            powerUP.name = "powerup"
            powerUP.physicsBody?.categoryBitMask = CollisionCategoryPowerUpOrbs
            powerUP.physicsBody?.collisionBitMask = 0
            
            foreground.addChild(powerUP)
            
        }
    }
    
    func circleBall(){
        
        //let Positions: [CGPoint] = [CGPointMake(self.size.width-100, 400),CGPointMake(self.size.width+100, 400),CGPointMake(self.size.width, 500),CGPointMake(self.size.width-100, 300)]
        

        
        for i in 0 ... 3{
        let Dia = 200 + i*30
        let circleBall = SKSpriteNode(imageNamed: "hole")
        circleBall.position = CGPointMake(self.size.width/2, CGFloat(600+i*600))
        let circleDiameter = CGFloat(Dia)
        let pathCenterPoint = CGPoint(x: circleBall.position.x-(circleDiameter/2), y: circleBall.position.y-(circleDiameter/2) )
        let circlePath =  CGPathCreateWithEllipseInRect(CGRect(origin: pathCenterPoint, size: CGSize(width: circleDiameter, height: circleDiameter)),nil)
        let followCirclePath =  SKAction.followPath(circlePath, asOffset: false, orientToPath: true, duration: 2)
        circleBall.physicsBody = SKPhysicsBody(circleOfRadius: circleBall.size.width/2)
        circleBall.physicsBody?.dynamic = false
        circleBall.name = "hole"
        
        circleBall.physicsBody?.categoryBitMask = CollisionCategoryHole
        circleBall.physicsBody?.collisionBitMask = 0
        circleBall.runAction(SKAction.repeatActionForever(followCirclePath))
        foreground.addChild(circleBall)
        }
        
    }
    
    func someLine(){
        
        let lineNode = SKSpriteNode(imageNamed: "line")
        
        lineNode.position = CGPointMake(self.size.width/2, 800)
        
        let circleDiameter = CGFloat(100)
        let pathCenterPoint = CGPoint(x: lineNode.position.x - circleDiameter, y: lineNode.position.y - circleDiameter)
        let circlePath =  CGPathCreateWithEllipseInRect(CGRect(origin: pathCenterPoint, size: CGSize(width: circleDiameter, height: circleDiameter)),nil)
        let followCirclePath =  SKAction.followPath(circlePath, asOffset: false, orientToPath: true, duration: 2)
        
        lineNode.physicsBody = SKPhysicsBody(circleOfRadius: lineNode.size.width/2)
        lineNode.physicsBody?.dynamic = false
        lineNode.name = "line"
        
        lineNode.physicsBody?.categoryBitMask = CollisionCategoryLine
        lineNode.physicsBody?.collisionBitMask = 0
        lineNode.runAction(SKAction.repeatActionForever(followCirclePath))
        foreground.addChild(lineNode)
    }
    
    deinit{
        self.coreMotionManager.stopAccelerometerUpdates()
    }
}