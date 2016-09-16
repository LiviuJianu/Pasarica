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
	var bounceTimer:Timer!
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

	override func didMove(to view: SKView) {
		viewSize = self.size
		
		createBackground()
		visibleNodes.speed = 0
		pipes.speed = 0;
		self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)

		
		bounceTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(MenuScene.animatePlay), userInfo: nil, repeats: true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	 
		if let touch = touches.first{

		let touchLocation = touch.location(in: self)
		
		if (playButton.contains(touchLocation)) {
			self.switchToPlay()
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
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
		
		upTexture.filteringMode = SKTextureFilteringMode.nearest
		downTexture.filteringMode = SKTextureFilteringMode.nearest
		
		bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 0.8)
		
		
		let animation = SKAction.animate(with: [upTexture,downTexture], timePerFrame: 0.2)
		let flap = SKAction.repeatForever(animation)
		bird.run(flap)
		
		bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
		bird.physicsBody?.isDynamic = true
		bird.physicsBody?.allowsRotation = false
		
		bird.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
		bird.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue
		bird.physicsBody?.contactTestBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue
		
		self.addChild(bird)
	}
	
	internal func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: TimeInterval(0.01 * groundTexture.size().width))
		let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
		let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		var i : CGFloat = 0
		while i < CGFloat(2) + self.frame.size.width / (groundTexture.size().width) {
			i += 1
			let sprite = SKSpriteNode(texture: groundTexture)
			sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2)
			sprite.run(moveGroundSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Ground - lower screen limit
		let groundLimit = SKNode()
		groundLimit.position = CGPoint(x: 0, y: groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height))
		groundLimit.physicsBody?.isDynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		self.addChild(groundLimit)
		
	}
	
	internal func drawSky(sky skylineTexture:SKTexture, ground groundTexture : SKTexture) {
		skylineTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveSkylineSprite = SKAction.moveBy(x: -skylineTexture.size().width, y: 0, duration: TimeInterval(0.01 * skylineTexture.size().width))
		let resetSkylineSprite = SKAction.moveBy(x: skylineTexture.size().width, y: 0, duration: 0.0)
		let moveSkylineSpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		
		var j : CGFloat = 0
		while j < CGFloat(2) + self.frame.size.width / (skylineTexture.size().width) {
			j += 1
			let sprite = SKSpriteNode(texture: skylineTexture)
			sprite.zPosition = -20
			sprite.position = CGPoint(x: j * sprite.size.width, y: sprite.size.height / 2 + groundTexture.size().height)
			sprite.run(moveSkylineSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPoint(x: 0, y: self.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		skyLimit.physicsBody?.isDynamic = false
		
		self.addChild(skyLimit)
	}
	
	internal func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.nearest
		
		//movement of pipes
		let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
		let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
		let removePipes = SKAction.removeFromParent()
		
		let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
		let pipeGap : CGFloat = 130.0
		
		//Spawn Pipes
		let spawn = SKAction.run({() in self.spawnPipes(pipesMoveAndRemove, gap: pipeGap, upTexture: pipeUpTexture, downTexture: pipeDownTexture)})
		let delay = SKAction.wait(forDuration: TimeInterval(2.0))
		let spawnThenDelay = SKAction.sequence([spawn,delay])
		let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
		
		self.run(spawnThenDelayForever)
	}
	
	internal func spawnPipes(_ pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
		let pipePair = SKNode()
		pipePair.position = CGPoint(x: self.frame.size.width + pipeUpTexture.size().width * 2.0, y: 0)
		pipePair.zPosition = -10
		
		let height = UInt32(self.frame.height / 3)
		let y = arc4random() % height
		
		let pipeDown = SKSpriteNode(texture: pipeDownTexture)
		pipeDown.position = CGPoint(x: 0.0, y: CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
		
		pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
		pipeDown.physicsBody?.isDynamic = false
		pipeDown.physicsBody?.categoryBitMask = CollisionCategory.pipe.rawValue
		pipeDown.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		
		pipePair.addChild(pipeDown)
		
		let pipeUp = SKSpriteNode(texture: pipeUpTexture)
		pipeUp.position = CGPoint(x: 0.0, y: CGFloat(y))
		
		pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
		pipeUp.physicsBody?.isDynamic = false
		pipeUp.physicsBody?.categoryBitMask = CollisionCategory.pipe.rawValue
		pipeUp.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(pipeUp)
		
		let contactNode = SKNode()
		contactNode.position = CGPoint(x: pipeUp.size.width + bird.size.width / 2, y: self.frame.midY)
		contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.frame.size.height))
		contactNode.physicsBody?.isDynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.run(pipesMoveAndRemove)
		pipes.addChild(pipePair)
		
	}

	func drawGameLabel() {
		// Game Label
		let gameLabel = SKLabelNode(fontNamed: "Helvetica")
		gameLabel.text = "pasarica"
		gameLabel.position = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
		gameLabel.fontSize = 72
		gameLabel.fontColor = SKColor.white
		gameLabel.zPosition = -10
		self.addChild(gameLabel)
	}
	
	func drawPlayLabel() {
		// Play Button
		playButton = SKLabelNode(fontNamed: "Helvetica")
		playButton.text = "joaca"
		playButton.position =  CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.65)
		playButton.fontSize = 96
		playButton.fontColor = SKColor.red
		playButton.zPosition = -10
		self.addChild(playButton)
	}
	
	func animatePlay () {
		let bounceLarger = SKAction.scale(to: 1.25, duration: 0.15)
		let bounceNormal = SKAction.scale(to: 1.0, duration: 0.15)
		let bounceSequence = SKAction.sequence([bounceLarger, bounceNormal])
		playButton.run(SKAction.repeat(bounceSequence, count: 3))
	}
	
	func switchToPlay () {
		bounceTimer.invalidate()
		do {
		if let scene = try GameScene.unarchiveFromFile("GameScene") as? GameScene {
			// Configure the view.
			let skView = view! as SKView
			skView.showsFPS = true
			skView.showsNodeCount = true
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			skView.ignoresSiblingOrder = true
			
			/* Set the scale mode to scale to fit the window */
			scene.scaleMode = .aspectFill
			let gameTransition = SKTransition.fade(with: SKColor.black, duration: 0.15)
			skView.presentScene(scene, transition: gameTransition)
		}
		} catch {
			print("Switch to play error")
		}
		
		
	}
	
}
