//
//  GameScene.swift
//  Pasarica
//
//  Created by Liviu Jianu on 15/09/14.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var skyColor = SKColor()
    var pipeUpTexture = SKTexture() 
    var pipeDownTexture = SKTexture()
    var PipesMoveAndRemove = SKAction()
	
	var gravity = CGFloat(-5.0)
	
    let pipeGap = 130.0
	let birdCategory: UInt32	= 1 << 0
	let worldCategory: UInt32	= 1 << 1
	let pipeCategory: UInt32	= 1 << 2
	let scoreCategory: UInt32	= 1 << 3
	
	var moving = SKNode()
	var canRestart = false
	
	var pipes = SKNode()
	
	var scoreLabelNode = SKLabelNode()
	var score = NSInteger()

	var highscore : Int {
		get {
			if let high = NSUserDefaults.standardUserDefaults().objectForKey("highscore") as? Int	{
				return high
			} else {
				self.highscore = 0 // this calls the setter
				return 0
			}
		}
		set (newHighscore){
			NSUserDefaults.standardUserDefaults().setInteger(newHighscore, forKey: "highscore")
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	var highScoreLabelNode = SKLabelNode()
	
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
		
		self.addChild(moving)
		moving.addChild(pipes)
		
        skyColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        //Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, gravity);
		self.physicsWorld.contactDelegate = self
        
        //Bird
        var BirdUpTexture = SKTexture(imageNamed: "BirdUp")
        BirdUpTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var BirdDownTexture = SKTexture(imageNamed: "BirdDown")
		BirdDownTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var animation = SKAction.animateWithTextures([BirdUpTexture,BirdDownTexture], timePerFrame: 0.2)
		var flap = SKAction.repeatActionForever(animation)
		
        bird = SKSpriteNode(texture: BirdUpTexture)
        bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		
		bird.runAction(flap)
		
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
		
		bird.physicsBody?.categoryBitMask = birdCategory
		bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
		bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(bird)
        
        //Ground
        var groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * groundTexture.size().width))
        var resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        var moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i: CGFloat = 0; i<2 + self.frame.size.width / (groundTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)

        }
        
        var skylineTexture = SKTexture(imageNamed: "Skyline")
        skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * skylineTexture.size().width))
        var resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0.0)
        var moveSkylineSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
        
        for var i: CGFloat = 0; i<2 + self.frame.size.width / (skylineTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: skylineTexture)
            sprite.zPosition = -20
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height)
            sprite.runAction(moveSkylineSpritesForever)
            moving.addChild(sprite)
            
        }

		var sky = SKNode()
		sky.position = CGPointMake(0, self.frame.size.height)
		sky.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1.0))
		sky.physicsBody?.categoryBitMask = worldCategory
		sky.physicsBody?.dynamic = false
		
		self.addChild(sky)
		
		var ground = SKNode()
        
        ground.position = CGPointMake(0, groundTexture.size().height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height))
        ground.physicsBody?.dynamic = false
		ground.physicsBody?.categoryBitMask = worldCategory
		self.addChild(ground)
        
        //Pipes
        
        //Create the Pipes
        pipeUpTexture = SKTexture(imageNamed: "PipeUp")
		pipeUpTexture.filteringMode = SKTextureFilteringMode.Nearest
        pipeDownTexture = SKTexture(imageNamed: "PipeDown")
		pipeDownTexture.filteringMode = SKTextureFilteringMode.Nearest
        //movement of pipes
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        
        PipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
        
        //Spawn Pipes
        
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
		
		score = 0
		scoreLabelNode.fontName = "Helvetica-Bold"
		scoreLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 6)
		scoreLabelNode.fontSize = 600
		scoreLabelNode.alpha = 0.2
		scoreLabelNode.zPosition = -30
		scoreLabelNode.text = "\(score)"
		self.addChild(scoreLabelNode)
		
		highScoreLabelNode.fontName = "Helvetica"
		highScoreLabelNode.fontSize = 20
		highScoreLabelNode.position = CGPointMake(self.frame.width - 400.0 , self.frame.height - highScoreLabelNode.fontSize)

		highScoreLabelNode.alpha = 0.5
		highScoreLabelNode.zPosition = -30

		highScoreLabelNode.text = "record: " + "\(self.highscore)"
		self.addChild(highScoreLabelNode)
        
    }
    
    func spawnPipes() {
        
        let pipePair = SKNode()
        pipePair.position = CGPointMake(self.frame.size.width + pipeUpTexture.size().width * 2.0, 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.height / 3)
        let y = arc4random() % height
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
		pipeDown.physicsBody?.categoryBitMask = pipeCategory
		pipeDown.physicsBody?.contactTestBitMask = birdCategory
        
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
		pipeUp.physicsBody?.categoryBitMask = pipeCategory
		pipeUp.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
		
		var contactNode = SKNode()
		contactNode.position = CGPointMake(pipeUp.size.width + bird.size.width / 2, CGRectGetMidY(self.frame))
		contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
		contactNode.physicsBody?.dynamic = false
		contactNode.physicsBody?.categoryBitMask = scoreCategory
		contactNode.physicsBody?.contactTestBitMask = birdCategory
		pipePair.addChild(contactNode)
		
        
        pipePair.runAction(PipesMoveAndRemove)
        pipes.addChild(pipePair)
        
    }
	
	func resetScene() {
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		bird.physicsBody?.velocity = CGVectorMake(0, 0)
		bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
		bird.speed = 1.0
		bird.zRotation = 0.0
		
		pipes.removeAllChildren()
		
		canRestart = false
		
		moving.speed = 1

		highScoreLabelNode.text = "record: \(self.highscore)"

		score = 0
		scoreLabelNode.text = "\(score)"
		
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
		
		if(moving.speed > 0) {
			
		    bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 3))
			
		} else if(canRestart) {
			self.resetScene()
		}
    }
	
	func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
		if(value>max) {
			return max
		} else if(value < min) {
			return min
		} else {
			return value
		}
	}
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
		
		if(moving.speed > 0) {
		var birdVelocity = bird.physicsBody?.velocity.dy
		bird.zRotation = self.clamp(-1, max: 0.5, value: birdVelocity! * (birdVelocity! < 0.0 ? 0.003 : 0.001))
		}
    }
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		if(moving.speed > 0) {
			
			if((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory) {
				score++
				scoreLabelNode.text = "\(score)"
				
				self.highscore = max(score, self.highscore);
			} else {

			moving.speed = 0
			bird.physicsBody?.collisionBitMask = worldCategory
			
			var rotateBird = SKAction.rotateByAngle(0.01, duration: 0.003)
			var stopBird = SKAction.runBlock({() in self.killBirdSpeed()})
			var birdSequence = SKAction.sequence([rotateBird,stopBird])
			bird.runAction(birdSequence)
		
		self.removeActionForKey("flash")
		var turnBackgroundRed = SKAction.runBlock({() in self.setBackgroundRed()})
		var wait = SKAction.waitForDuration(0.05)
		var turnBackgroundWhite = SKAction.runBlock({() in self.setBackgroundColorWhite()})
		var turnBackgoundColorSky = SKAction.runBlock({() in self.setBackgroundColorSky()})
		
		var sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgoundColorSky])
		var repeatSequence = SKAction.repeatAction(sequenceOfActions, count: 4)
		var canRestartAction = SKAction.runBlock({() in self.letItRestart()})
		var groupOfActions = SKAction.group([repeatSequence, canRestartAction])
		
		self.runAction(groupOfActions, withKey:"flash")
			}
		}
	}
	
	func killBirdSpeed() {
		bird.speed = 0
	}
	
	func letItRestart() {
		canRestart = true
	}
	
	func setBackgroundRed() {
		self.backgroundColor = UIColor.redColor()
	}
	func setBackgroundColorWhite() {
		self.backgroundColor = UIColor.whiteColor()
	}
	func setBackgroundColorSky() {
		self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
	}
}
