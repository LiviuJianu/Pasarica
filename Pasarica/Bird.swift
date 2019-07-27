//
//  Bird.swift
//  Pasarica
//
//  Created by Liviu Jianu on 20/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

final class Bird: SKSpriteNode {
	
	private let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
	private let birdDownTexture = SKTexture(imageNamed: "BirdDown")
	
	init() {
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
	
	func flyBird(_ impulseValue : CGFloat) {
		
		self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		self.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue

		let impulse = CGVector(dx: 0, dy: impulseValue)
		self.physicsBody?.applyImpulse(impulse)
		
	}
	
}
