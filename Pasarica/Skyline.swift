//
//  Skyline.swift
//  Pasarica
//
//  Created by Liviu Jianu on 27/07/2019.
//  Copyright © 2019 Liviu Jianu. All rights reserved.
//

import SpriteKit

class Skyline: SKNode {

	
	let skylineTexture  = SKTexture(imageNamed: "Skyline")
	let GROUND_HEIGHT: CGFloat = 112

	init(frame: CGRect) {
		super.init()
		self.drawSky(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawSky(frame: CGRect) {
		skylineTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveSkylineSprite = SKAction.moveBy(x: -skylineTexture.size().width, y: 0, duration: TimeInterval(0.01 * skylineTexture.size().width))
		let resetSkylineSprite = SKAction.moveBy(x: skylineTexture.size().width, y: 0, duration: 0.0)
		let moveSkylineSpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		for i in 0...3 {
			let skylineNode = SKSpriteNode(texture: skylineTexture)
			skylineNode.zPosition = -20
			skylineNode.name = "Skyline"
			skylineNode.position = CGPoint(x: CGFloat(i) * skylineNode.size.width, y: skylineNode.size.height / 2 + GROUND_HEIGHT)
			skylineNode.run(moveSkylineSpritesForever)
			self.addChild(skylineNode)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPoint(x: 0, y: frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width, height: 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		skyLimit.physicsBody?.isDynamic = false
		
	}
}
