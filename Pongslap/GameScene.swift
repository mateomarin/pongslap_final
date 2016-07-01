//
//  GameScene.swift
//  Pongslap
//
//  Created by Mateo Marin on 3/16/16.
//  Copyright (c) 2016 Mateo Marin. All rights reserved.
//

import SpriteKit
import UIKit
import CoreMotion
import AudioToolbox
import AVFoundation
import MobileCoreServices

class GameScene: SKScene, UIAlertViewDelegate, UINavigationControllerDelegate, GameSceneDelegate {
    
    var score: SKLabelNode = SKLabelNode()
    var gameOver: SKLabelNode = SKLabelNode()
    var highScore: SKLabelNode = SKLabelNode()
    var newHighScore: SKLabelNode = SKLabelNode()
    var controller: GameViewController?
    
    var spriteArray: [String] = ["3dBall", "Trump"]
    var backgroundArray = [["background1"], ["hell", "jail"]]
    var buttonArray = ["hellButton", "normalButton"]
    var paddleArray = [["pingPong", "pingPong2"], ["fronthand", "backhand"]]
    var countryArray = ["usaButton", "brazilButton"]
    var faceArray = ["Trump", "lula"]
    var soundArray = ["pinghit","slap"]
    var dimensionsArray = [[0.40, 0.75], [0.25, 0.40]]
    
    var buttonPressed = 0
    var countryPressed = 0
    var count = 0
    var cyclecount = 0
    var div: CGFloat = 4
    var origin : CGPoint = CGPoint()
    var actualDuration = 1.0
    var play = true
    var rand: CGPoint = CGPoint(x: 0, y: 0)
    var rand2: CGPoint = CGPoint(x: 0, y: 0)
    var timer = NSTimer()
    var crackArray: [SKSpriteNode] = []
    var crackCount = 0
    var gameScores: [Int] = []
    var mode = 0
    var point = 1
    var hitPoint = 0
    
    var lost = false
    
    var sprite = SKSpriteNode(imageNamed: "3dBall")
    var backShadow = SKSpriteNode(imageNamed:"shadow")
    var sideShadow = SKSpriteNode(imageNamed:"sideShadow")
    var hellButton = SKSpriteNode(imageNamed:"hellButton")
    let background = SKSpriteNode(imageNamed: "background1")
    var countryButton = SKSpriteNode(imageNamed: "usaButton")
    
    
    //paddle variables
    var paddle = SKSpriteNode(imageNamed:"pingPong")
    var paddleXpos:CGFloat = 0.0
    var paddleYpos:CGFloat = 0.0
    var paddle_dX:String = ""
    var paddle_dY:String = ""
    
    //Instance Variables
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    var currentAccelX: Double = 0.0
    var currentAccelY: Double = 0.0
    var currentAccelZ: Double = 0.0
    var currentRotX: Double = 0.0
    var currentRotY: Double = 0.0
    var currentRotZ: Double = 0.0
    
    var movementManager = CMMotionManager()
    
    var slapSound = AVAudioPlayer()
    var paddleSound = AVAudioPlayer()
    var evilLaugh = AVAudioPlayer()
    
    
    var specialEnabled = false
    var specialThreshold = 1

    var testHit = false
    
    func runSeq(){
        cyclecount++
        
        hitPoint = 0
        
        rand = CGPoint(x: Int(arc4random_uniform(UInt32(320)) + 350), y: Int(arc4random_uniform(UInt32(600)) + 100))
        //rand2 = CGPoint(x: Double(arc4random_uniform(UInt32(220)) + 390), y: Double(arc4random_uniform(UInt32(400)) + 200))
        
        print("rand: \(self.rand)")
        
        if specialEnabled {
            specialEnabled = false
            point = 1
            sprite.colorBlendFactor = 0
        }
        let randNum = Int(arc4random_uniform(100))
        if randNum <= specialThreshold {
            specialEnabled = true
            point = 2
            sprite.color = .redColor()
            sprite.colorBlendFactor = 0.8
        }
        
        
        //rand = CGPoint(x: 620, y: Int(CGRectGetMidY(self.frame)))
        //print("rand")
        //print(rand)
        //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        
        let forward = SKAction.moveTo(rand, duration: NSTimeInterval(actualDuration))
        let forward2 = SKAction.scaleBy(div, duration: NSTimeInterval(actualDuration))
        let backward = SKAction.moveTo(origin, duration: NSTimeInterval(actualDuration))
        let backward2 = SKAction.scaleBy(1/div, duration: NSTimeInterval(actualDuration))
        let shadowIncrease = SKAction.scaleBy(100, duration: NSTimeInterval(actualDuration))
        let shadowDecrease = SKAction.scaleBy(1/100, duration: NSTimeInterval(actualDuration))
        
        let forwardShadow = SKAction.moveTo(CGPoint(x: 800, y: rand.y), duration: NSTimeInterval(actualDuration))
        let backwardShadow = SKAction.moveTo(CGPoint(x: 620, y: origin.y), duration: NSTimeInterval(actualDuration))
        
        let zChange1 = SKAction.runBlock({
            self.sprite.zPosition = 0
        })
        let zChange2 = SKAction.runBlock({
            self.sprite.zPosition = -1
        })
        let hitPrompt = SKAction.runBlock({
            self.testHit = true
        })
        let backPrompt = SKAction.runBlock({
            print("back")
        })
        
        
        let firstgroup = SKAction.group([forward, forward2])
        let secondgroup = SKAction.group([backward, backward2])
        
        let thirdgroup = SKAction.group([forwardShadow, forward2])
        let fourthgroup = SKAction.group([backwardShadow, backward2])
        
        let cycle = SKAction.sequence([firstgroup, hitPrompt, secondgroup, backPrompt])
        let cycle2 = SKAction.sequence([shadowDecrease, shadowIncrease])
        let cycle3 = SKAction.sequence([thirdgroup, fourthgroup])
        
        //let wait = SKAction.waitForDuration(NSTimeInterval(1.0))
        sprite.runAction(cycle)
        backShadow.runAction(cycle2)
        sideShadow.runAction(cycle3)
        
    }
    
    
    //CoreMotion Functions
    
    func outputAccData(acceleration: CMAcceleration){
        
        currentAccelX = acceleration.x
        
        if fabs(acceleration.x) > fabs(currentMaxAccelX)
        {
            currentMaxAccelX = acceleration.x
        }
        
        currentAccelY = acceleration.y
        
        if fabs(acceleration.y) > fabs(currentMaxAccelY)
        {
            currentMaxAccelY = acceleration.y
        }
        
        currentAccelZ = acceleration.z
        
        if fabs(acceleration.z) > fabs(currentMaxAccelZ)
        {
            currentMaxAccelZ = acceleration.z
        }
        
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        if fabs(rotation.x) > fabs(currentMaxRotX)
        {
            currentMaxRotX = rotation.x
        }
        
        
        if fabs(rotation.y) > fabs(currentMaxRotY)
        {
            currentMaxRotY = rotation.y
        }
        
        if fabs(rotation.z) > fabs(currentMaxRotZ)
        {
            currentMaxRotZ = rotation.z
        }
        
    }
    
    override func didMoveToView(view: SKView) {

        
        //SOUNDS SETUP
        // Slap sound
        let slap = NSBundle.mainBundle().pathForResource("slap", ofType: "m4a")
        if let slap = slap{
            let myPathURL = NSURL(fileURLWithPath: slap)
            
            do{
                try slapSound = AVAudioPlayer(contentsOfURL: myPathURL)
            } catch{
                print("error")
            }
        }
        
        //Paddle Sound
        let hit = NSBundle.mainBundle().pathForResource("pinghit", ofType: "m4a")
        if let hit = hit{
            let myPathURL = NSURL(fileURLWithPath: hit)
            
            do{
                try paddleSound = AVAudioPlayer(contentsOfURL: myPathURL)
            } catch{
                print("error")
            }
        }
        
        //Evil laugh
        let laugh = NSBundle.mainBundle().pathForResource("evil", ofType: "m4a")
        if let laugh = laugh{
            let myPathURL = NSURL(fileURLWithPath: laugh)
            
            do{
                try evilLaugh = AVAudioPlayer(contentsOfURL: myPathURL)
            } catch{
                print("error")
            }
        }

        //COLORS LULA'S PRISON
        //self.backgroundColor = UIColor.redColor()
        
        //SCORE SPRITE
        score = SKLabelNode(fontNamed:"Optima-ExtraBlack")
        score.text = "0"
        score.fontSize = 160
        score.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-50)
        print(self.frame)
        score.zPosition = -2
        score.alpha = 0.65
        self.addChild(score)
        
        //BACKGROUND SPRITE
        background.zPosition = -4
        background.xScale = 0.4
        background.yScale = 0.4
        background.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        if mode == 0 {
            background.runAction(SKAction.rotateByAngle(1.5708, duration: 0))
        } else {
            background.runAction(SKAction.rotateByAngle(4.71239, duration: 0))
        }
        self.addChild(background)
        
        
        //GAMEOVER SPRITE
        gameOver = SKLabelNode(fontNamed:"Futura-CondensedExtraBold")
        gameOver.text = "GAME OVER"
        gameOver.fontSize = 80
        gameOver.alpha = 0.8
        gameOver.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-30)
        gameOver.zPosition = 3
        self.addChild(gameOver)
        gameOver.hidden = true
        
        //HIGHSCORE SPRITE
        highScore = SKLabelNode(fontNamed:"Futura-CondensedExtraBold")
        highScore.fontSize = 40
        highScore.alpha = 0.8
        highScore.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-80)
        highScore.zPosition = 3
        self.addChild(highScore)
        highScore.hidden = true
        
        //NEW HIGHSCORE ANNOUNCEMENT
        newHighScore = SKLabelNode(fontNamed:"Futura-CondensedExtraBold")
        newHighScore.text = "NEW HIGHSCORE!"
        newHighScore.fontSize = 40
        newHighScore.alpha = 0.8
        newHighScore.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) + 30)
        newHighScore.zPosition = 3
        self.addChild(newHighScore)
        newHighScore.hidden = true
        
        //PADDLE SPRITE
        paddleXpos = CGRectGetMidX(self.frame)
        paddleYpos = CGRectGetMidY(self.frame)
        paddle.xScale = 0.1
        paddle.yScale = 0.1
        paddle.zPosition = 1
        paddle.position = CGPoint(x:paddleXpos, y:paddleYpos)
        self.addChild(paddle)
        print(paddle.zPosition)
        
        //PADDLE MOVEMENT
        //Set Motion Manager Properties
        //(2/10ths of a second intervals)
        movementManager.accelerometerUpdateInterval = 0.05
        movementManager.gyroUpdateInterval = 0.05
        
        //Start Recording Data
        movementManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        movementManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
        })
        
        //BUTTON TO GO TO HELL MODE
        hellButton = SKSpriteNode(imageNamed: buttonArray[mode])
        hellButton.xScale = 0.7
        hellButton.yScale = 0.7
        hellButton.position = CGPoint(x: 390, y: 700)
        hellButton.zPosition = 1
        self.addChild(hellButton)

        
        //BUTTON TO CHANGE FACES
        countryButton = SKSpriteNode(imageNamed: countryArray[mode])
        countryButton.xScale = 0.7
        countryButton.yScale = 0.7
        countryButton.position = CGPoint(x: 640, y: 700)
        countryButton.zPosition = 1
        self.addChild(countryButton)
        countryButton.hidden = true
        
        //BALL SPRITE
        sprite = SKSpriteNode(imageNamed: spriteArray[mode])
        sprite.zPosition = -1
        sprite.xScale = 0.04
        sprite.yScale = 0.04
        origin = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        rand = origin
        sprite.position = origin
        self.addChild(sprite)
        
        //STRAIGHTEN UP SPRITES WHEN ALTERNATING MODES
        if mode == 0 {
            sprite.runAction(SKAction.rotateByAngle(1.5708, duration: 0))
        } else {
            sprite.runAction(SKAction.rotateByAngle(4.71239, duration: 0))
        }
        
        //BALL SHADOW TRAILING ON THE RIGHT
        sideShadow.alpha = 0.3
        sideShadow.xScale = 0.2
        sideShadow.yScale = 0.2
        sideShadow.position = CGPoint(x: 620, y:CGRectGetMidY(self.frame))
        sideShadow.zPosition = -3
        self.addChild(sideShadow)
        
        //BALL SHADOW ON THE BACK WALL
        backShadow.alpha = 0.1
        backShadow.xScale = 0.2
        backShadow.yScale = 0.2
        backShadow.position = origin
        backShadow.zPosition = -3
        self.addChild(backShadow)
        
        //TIMER REPEATS THE BOUNCING BACK AND FORTH MOVEMENT
        timer = NSTimer.scheduledTimerWithTimeInterval(actualDuration*2, target: self, selector: "runSeq", userInfo: nil, repeats: true)
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if testHit == true && cyclecount > 0 && hitPoint == 0 {
            print("success")
            testHit = false
            if sprite.position.x <= paddle.position.x + paddle.size.width/2 &&
                sprite.position.x >= paddle.position.x - paddle.size.width/2 &&
                sprite.position.y <= paddle.position.y + paddle.size.height/2 &&
                sprite.position.y >= paddle.position.y - paddle.size.height/2 &&
                !lost {
                    count += point
                    
                    hitPoint = 1
                    
                    let paddleMotion: NSTimeInterval = 0.1
                    let paddleMotion2: NSTimeInterval = 0.3
                    
                    let padchange = SKAction.runBlock({
                        self.paddle.texture = SKTexture(imageNamed: self.paddleArray[self.mode][1])
                        if self.mode == 1 {
                            self.slapSound.play()
                        } else {
                            self.paddleSound.play()
                        }
                    })
                    
                    let wait = SKAction.waitForDuration(paddleMotion2)
                    
                    let padchange2 = SKAction.runBlock({
                        self.paddle.texture = SKTexture(imageNamed: self.paddleArray[self.mode][0])
                    })
                    
                    
                    paddle.runAction(SKAction.sequence([padchange, wait, padchange2]))
                    
                    if mode == 1 {
                        sprite.runAction(SKAction.rotateByAngle(12.5664, duration: NSTimeInterval(actualDuration)))
                    }
                    
                    let hit = SKAction.rotateByAngle(0.5, duration: paddleMotion)
                    let returnHit = SKAction.rotateByAngle(-0.5, duration: paddleMotion)
                    paddle.runAction(SKAction.sequence([hit, returnHit]))
                    
                    if !lost {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                    
                    score.text = String(count)
                    
            } else {
                
                let crack = SKSpriteNode(imageNamed: "crack")
                crackCount++
                crackArray.append(crack)
                crack.position = CGPoint(x: rand.x, y: rand.y)
                self.addChild(crack)
                if crackCount == 5 {
                    
                    self.controller!.canDisplayBannerAds = true
                    if mode == 1 {
                        evilLaugh.play()
                    }
                    self.removeChildrenInArray(crackArray)
                    crackCount = 0
                    let oldHighScore = gameScores.maxElement()
                    gameScores.append(Int(score.text!)!)
                    
                    sprite.runAction(SKAction.scaleBy(10, duration: 0))
                    sprite.runAction(SKAction.scaleBy(1/10, duration: 0))
                    
                    count = 0
                    score.text = "0"
                    actualDuration = 1.0
                    
                    if gameScores.maxElement() != oldHighScore {
                        newHighScore.hidden = false
                        gameOver.position.y -= 20
                        highScore.position.y -= 20
                    }
                    gameOver.hidden = false
                    paddle.hidden = true
                    score.hidden = true
                    
                    highScore.text = "SESSION HIGHSCORE: \(gameScores.maxElement()!)"
                    highScore.hidden = false
                    
                    lost = true
                    
                }
            }
            
            if Int(score.text!)! >= 5 && Int(score.text!)!%5 == 0 {
                actualDuration *= 0.8
            }
        }
        
        
        /* Called before each frame is rendered */
        
        if( paddleXpos + (50 * CGFloat(currentAccelX)) < CGRectGetMaxX(self.frame)-350 && paddleXpos + (50 * CGFloat(currentAccelX)) > 350.0) {
            paddleXpos+=40*CGFloat(currentAccelX)
        }
        
        if( paddleYpos + (50 * CGFloat(currentAccelY)) < CGRectGetMaxY(self.frame)-70 && paddleYpos + (50 * CGFloat(currentAccelY)) > 70.0) {
            paddleYpos+=40*CGFloat(currentAccelY)
        }
        paddle.position = CGPoint(x:paddleXpos, y:paddleYpos)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        if hellButton.containsPoint(touch.locationInNode(self)){
            buttonPressed++
            print("touched")
            mode = buttonPressed%2
            
            hellButton.texture = SKTexture(imageNamed: buttonArray[mode])
            sprite.texture = SKTexture(imageNamed: spriteArray[mode])
            background.texture = SKTexture(imageNamed: backgroundArray[mode][0])
            paddle.texture = SKTexture(imageNamed: paddleArray[mode][0])
            
            if mode == 0 {
                sprite.runAction(SKAction.rotateByAngle(1.5708, duration: 0))
                background.runAction(SKAction.rotateByAngle(1.5708, duration: 0))
                background.xScale = 0.4
                background.yScale = 0.4
                countryButton.hidden = true
            } else {
                sprite.runAction(SKAction.rotateByAngle(-1.5708, duration: 0))
                background.runAction(SKAction.rotateByAngle(-1.5708, duration: 0))
                background.xScale = CGFloat(dimensionsArray[0][0])
                background.yScale = CGFloat(dimensionsArray[0][1])
                countryButton.hidden = false
            }
        }
        
        
        if countryButton.containsPoint(touch.locationInNode(self)){
            countryPressed++
            
            sprite.texture = SKTexture(imageNamed: faceArray[countryPressed%2])
            background.texture = SKTexture(imageNamed: backgroundArray[mode][countryPressed%2])
            background.xScale = CGFloat(dimensionsArray[countryPressed%2][0])
            background.yScale = CGFloat(dimensionsArray[countryPressed%2][1])
            //background.size = self.frame.size
            countryButton.texture = SKTexture(imageNamed: countryArray[countryPressed%2])
            
        }
        
        if lost {
            self.controller!.canDisplayBannerAds = false
            self.removeChildrenInArray(crackArray)
            crackCount = 0
            
            score.text = "0"
            paddle.hidden = false
            score.hidden = false
            lost = false
            
            if !newHighScore.hidden {
                gameOver.position.y += 20
                highScore.position.y += 20
                newHighScore.hidden = true
            }
            
            highScore.hidden = true
            gameOver.hidden = true
        }
    }
    
}



