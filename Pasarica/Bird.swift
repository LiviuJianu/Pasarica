//
//  Bird.swift
//  Pasarica
//
//  Created by Liviu Jianu on 20/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

final class Bird: SKSpriteNode {
	
	var gameFrame: CGRect
	
	private let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
	private let birdDownTexture = SKTexture(imageNamed: "BirdDown")
	
	init(frame: CGRect) {
		self.gameFrame = frame
		super.init(texture: birdUpTexture, color: UIColor.clear, size: birdUpTexture.size())
		
		self.name = "Bird"
		self.createBird(up: birdUpTexture, down: birdDownTexture)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func createBird(up upTexture : SKTexture, down downTexture : SKTexture) {
		upTexture.filteringMode = SKTextureFilteringMode.nearest
		downTexture.filteringMode = SKTextureFilteringMode.nearest
		
		self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		self.position = CGPoint(x: self.gameFrame.size.width / 2.8, y: self.gameFrame.midY)
		
		self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2.0)
		self.physicsBody?.isDynamic = true
		self.physicsBody?.allowsRotation = false
		
		self.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
		self.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue
		self.physicsBody?.contactTestBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue

		self.flapWings()
	}
	
	func flapWings() {
		let animation = SKAction.animate(with: [birdUpTexture,birdDownTexture], timePerFrame: 0.2)
		let flap = SKAction.repeatForever(animation)
		self.run(flap)
	}
	
	func update() {
		if let birdVelocity = self.physicsBody?.velocity.dy {
			
			var rotation : CGFloat = 0
	
			if (birdVelocity < 0.0){
				rotation = birdVelocity * 0.003;
			}
			else {
				rotation = birdVelocity * 0.001;
			}
			
			rotation = max(-1, min(0.5, rotation))
			
			self.zRotation = rotation
		}
	}
	
	func flyBird() {
		
		self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		
		let gameplayDict : NSDictionary = {
			let path = Bundle.main.path(forResource: "Gameplay", ofType: "plist")
			let dict = NSDictionary(contentsOfFile: path!)
			return dict!
		}()
		
		let impulseVector = gameplayDict.value(forKey: "Impulse-Vector") as! CGFloat
		let impulse = CGVector(dx: 0, dy: impulseVector)
		self.physicsBody?.applyImpulse(impulse)
	}
	
	func reset() {
		self.position = CGPoint(x: self.gameFrame.size.width / 2.8, y: self.gameFrame.midY)
		self.speed = 1.0
		self.zRotation = 0.0
		
		self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		self.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue
		
		if self.action(forKey: "stopBirdAction") != nil {
			self.removeAction(forKey: "stopBirdAction")
		}
	}
	
	func stop() {
		self.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue
		
		let rotateBird = SKAction.rotate(byAngle: 0.01, duration: 0.003)
		let stopBird = SKAction.run({() in self.stop()})
		let birdSequence = SKAction.sequence([rotateBird,stopBird])
		self.run(birdSequence, withKey: "stopBirdAction")
	}
	
}
