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

		drawGameLabel()
		drawPlayLabel()
		
		//Create the Bird
		createBird(up: birdUpTexture, down: birdDownTexture)

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

	func drawGameLabel() {
		// Game Label
		let gameLabel = SKLabelNode(fontNamed: "Helvetica")
		gameLabel.text = "pasarica"
		gameLabel.position = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
		gameLabel.fontSize = 72
		gameLabel.fontColor = SKColor.white
		gameLabel.zPosition = 100
		self.addChild(gameLabel)
	}
	
	func drawPlayLabel() {
		// Play Button
		playButton = SKLabelNode(fontNamed: "Helvetica")
		playButton.text = "joaca"
		playButton.position =  CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.65)
		playButton.fontSize = 96
		playButton.fontColor = SKColor.red
		playButton.zPosition = 100
		self.addChild(playButton)
	}
	
	@objc func animatePlay () {
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
			skView.showsFPS = false
			skView.showsNodeCount = false
			
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
