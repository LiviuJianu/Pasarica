//
//  MenuScene.swift
//  Pasarica
//
//  Created by Liviu Jianu on 18/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit
import AVFoundation

class MenuScene: SKScene, AVAudioPlayerDelegate {
	
	var playButton:SKLabelNode!
	var bounceTimer:NSTimer!
	var viewSize : CGSize!
	
	let bird = SKSpriteNode(texture: SKTexture(imageNamed: "BirdUp"))
	internal let pipes = SKNode()
	internal let visibleNodes = SKNode()
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	

	
	override init(size: CGSize) {
		super.init(size: size)
	}

	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		// set value of the highscore to the saved one, if any
	}

	override func didMoveToView(view: SKView) {
		viewSize = self.size
		
		createBackground()
		visibleNodes.speed = 0
		pipes.speed = 0;
		self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)

		
		bounceTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("animatePlay"), userInfo: nil, repeats: true)
	}
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let touch:UITouch = touches.anyObject() as UITouch
		let touchLocation = touch.locationInNode(self)
		
		if (playButton.containsPoint(touchLocation)) {
			self.switchToPlay()
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
	}

	
	func createBackground() {
		let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
		let birdDownTexture = SKTexture(imageNamed: "BirdDown")
		
		let groundTexture   = SKTexture(imageNamed: "Ground")
		let skylineTexture  = SKTexture(imageNamed: "Skyline")
		
		let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
		let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
		
		drawGameLabel()
		drawPlayLabel()
		
		
		//Create the Bird
		createBird(up: birdUpTexture, down: birdDownTexture)
		
		//Draw the Ground and set the limits
		drawGround(ground: groundTexture)
		
		//Draw the Sky and set the limits
		drawSky(sky: skylineTexture, ground: groundTexture)
		
		//Draw the pipes
		drawPipes(up: pipeUpTexture, down: pipeDownTexture)
		
		//Draw the score and high score
//		drawScores()
		
		self.addChild(visibleNodes)
		self.addChild(pipes)

	}
	
	internal func createBird(up upTexture : SKTexture, down downTexture : SKTexture) {
		
		upTexture.filteringMode = SKTextureFilteringMode.Nearest
		downTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) * 0.8)
		
		
		var animation = SKAction.animateWithTextures([upTexture,downTexture], timePerFrame: 0.2)
		var flap = SKAction.repeatActionForever(animation)
		bird.runAction(flap)
		
		bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
		bird.physicsBody?.dynamic = true
		bird.physicsBody?.allowsRotation = false
		
		bird.physicsBody?.categoryBitMask = CollisionCategory.Bird.rawValue
		bird.physicsBody?.collisionBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue
		bird.physicsBody?.contactTestBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue
		
		self.addChild(bird)
	}
	
	internal func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * groundTexture.size().width))
		var resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
		var moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		for var i: CGFloat = 0; i<2 + self.frame.size.width / (groundTexture.size().width); ++i {
			var sprite = SKSpriteNode(texture: groundTexture)
			sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
			sprite.runAction(moveGroundSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Ground - lower screen limit
		var groundLimit = SKNode()
		groundLimit.position = CGPointMake(0, groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height))
		groundLimit.physicsBody?.dynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.World.rawValue
		self.addChild(groundLimit)
		
	}
	
	internal func drawSky(sky skylineTexture:SKTexture, ground groundTexture : SKTexture) {
		skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * skylineTexture.size().width))
		var resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0.0)
		var moveSkylineSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		
		for var i: CGFloat = 0; i<2 + self.frame.size.width / (skylineTexture.size().width); ++i {
			var sprite = SKSpriteNode(texture: skylineTexture)
			sprite.zPosition = -20
			sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height)
			sprite.runAction(moveSkylineSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Sky - upper screen limit
		var skyLimit = SKNode()
		skyLimit.position = CGPointMake(0, self.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.World.rawValue
		skyLimit.physicsBody?.dynamic = false
		
		self.addChild(skyLimit)
	}
	
	internal func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.Nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		//movement of pipes
		let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
		let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
		let removePipes = SKAction.removeFromParent()
		
		let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
		let pipeGap : CGFloat = 130.0
		
		//Spawn Pipes
		let spawn = SKAction.runBlock({() in self.spawnPipes(pipesMoveAndRemove, gap: pipeGap, upTexture: pipeUpTexture, downTexture: pipeDownTexture)})
		let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
		let spawnThenDelay = SKAction.sequence([spawn,delay])
		let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
		
		self.runAction(spawnThenDelayForever)
	}
	
	internal func spawnPipes(pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
		let pipePair = SKNode()
		pipePair.position = CGPointMake(self.frame.size.width + pipeUpTexture.size().width * 2.0, 0)
		pipePair.zPosition = -10
		
		let height = UInt32(self.frame.height / 3)
		let y = arc4random() % height
		
		let pipeDown = SKSpriteNode(texture: pipeDownTexture)
		pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
		
		pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
		pipeDown.physicsBody?.dynamic = false
		pipeDown.physicsBody?.categoryBitMask = CollisionCategory.Pipe.rawValue
		pipeDown.physicsBody?.contactTestBitMask = CollisionCategory.Bird.rawValue
		
		pipePair.addChild(pipeDown)
		
		let pipeUp = SKSpriteNode(texture: pipeUpTexture)
		pipeUp.position = CGPointMake(0.0, CGFloat(y))
		
		pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
		pipeUp.physicsBody?.dynamic = false
		pipeUp.physicsBody?.categoryBitMask = CollisionCategory.Pipe.rawValue
		pipeUp.physicsBody?.contactTestBitMask = CollisionCategory.Bird.rawValue
		pipePair.addChild(pipeUp)
		
		var contactNode = SKNode()
		contactNode.position = CGPointMake(pipeUp.size.width + bird.size.width / 2, CGRectGetMidY(self.frame))
		contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
		contactNode.physicsBody?.dynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.Score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.Bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.runAction(pipesMoveAndRemove)
		pipes.addChild(pipePair)
		
	}

	func drawGameLabel() {
		// Game Label
		let gameLabel = SKLabelNode(fontNamed: "Helvetica")
		gameLabel.text = "pasarica"
		gameLabel.position = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
		gameLabel.fontSize = 72
		gameLabel.fontColor = SKColor.whiteColor()
		gameLabel.zPosition = -10
		self.addChild(gameLabel)
	}
	
	func drawPlayLabel() {
		// Play Button
		playButton = SKLabelNode(fontNamed: "Helvetica")
		playButton.text = "joaca"
		playButton.position =  CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.65)
		playButton.fontSize = 96
		playButton.fontColor = SKColor.redColor()
		playButton.zPosition = -10
		self.addChild(playButton)
	}
	
	func animatePlay () {
		let bounceLarger = SKAction.scaleTo(1.25, duration: 0.15)
		let bounceNormal = SKAction.scaleTo(1.0, duration: 0.15)
		let bounceSequence = SKAction.sequence([bounceLarger, bounceNormal])
		playButton.runAction(SKAction.repeatAction(bounceSequence, count: 3))
	}
	
	func switchToPlay () {
		bounceTimer.invalidate()
		
		if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
			// Configure the view.
			let skView = view! as SKView
			skView.showsFPS = true
			skView.showsNodeCount = true
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			skView.ignoresSiblingOrder = true
			
			/* Set the scale mode to scale to fit the window */
			scene.scaleMode = .AspectFill
			let gameTransition = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 0.15)
			skView.presentScene(scene, transition: gameTransition)
		}
		
		
	}
	
}