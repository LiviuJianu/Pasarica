//
//  Bird.swift
//  Pasarica
//
//  Created by Liviu Jianu on 20/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

class Bird: SKSpriteNode {
	
	let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
	let birdDownTexture = SKTexture(imageNamed: "BirdDown")
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
		
		self.createBird(up: birdUpTexture, down: birdDownTexture)
	}

	convenience init() {
		let birdTexture = SKTexture(imageNamed: "BirdUp")
		self.init(texture: birdTexture, color: UIColor.clearColor(), size: birdTexture.size())
	}

	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func createBird(up upTexture : SKTexture, down downTexture : SKTexture) {
		
		upTexture.filteringMode = SKTextureFilteringMode.Nearest
		downTexture.filteringMode = SKTextureFilteringMode.Nearest
	
		
		self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2.0)
		self.physicsBody?.dynamic = true
		self.physicsBody?.allowsRotation = false
		
		self.physicsBody?.categoryBitMask = CollisionCategory.Bird.rawValue
		self.physicsBody?.collisionBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue
		self.physicsBody?.contactTestBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue

		self.flapWings()
	}
	
	func flapWings() {
		let animation = SKAction.animateWithTextures([birdUpTexture,birdDownTexture], timePerFrame: 0.2)
		let flap = SKAction.repeatActionForever(animation)
		self.runAction(flap)
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
	
	func flyBird(impulseValue : CGFloat) {
		
		self.physicsBody?.velocity = CGVectorMake(0, 0)
		self.physicsBody?.collisionBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue

		let impulse = CGVectorMake(0, impulseValue)
		self.physicsBody?.applyImpulse(impulse)
		
	}
	
}
