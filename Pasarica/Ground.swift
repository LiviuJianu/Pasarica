//
//  Ground.swift
//  Pasarica
//
//  Created by Liviu Jianu on 27/07/2019.
//  Copyright © 2019 Liviu Jianu. All rights reserved.
//

import SpriteKit

final class Ground: SKNode {
	
	let groundTexture   = SKTexture(imageNamed: "Ground")

	init(frame: CGRect) {
		super.init()
		self.name = "Ground"
		self.drawGround(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawGround(frame: CGRect) {
		groundTexture.filteringMode = SKTextureFilteringMode.nearest
		
		//Ground moving actions
		let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: TimeInterval(0.01 * groundTexture.size().width))
		let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
		let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		//Position ground nodes on the screen
		for i in 0...3 {
			let groundNode = SKSpriteNode(texture: groundTexture)
			groundNode.name = "Ground-child-\(i)"
			groundNode.position = CGPoint(x: CGFloat(i) * groundNode.size.width, y: groundNode.size.height / 2)
			groundNode.run(moveGroundSpritesForever)
			self.addChild(groundNode)
		}
		
		
		//Ground Physics - lower screen limit
		let groundLimit = SKNode()
		groundLimit.position = CGPoint(x: 0, y: groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height))
		groundLimit.physicsBody?.isDynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		
		self.addChild(groundLimit)
		
	}
}
