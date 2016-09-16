//
//  Pipes.swift
//  Pasarica
//
//  Created by Liviu Jianu on 21/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

class Pipes : SKSpriteNode {
	
	let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
	let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
		
		self.drawPipes(up: pipeUpTexture, down: pipeDownTexture)
	}
	
	convenience init() {
		let pipeInitTexture = SKTexture(imageNamed: "PipeUp")
		self.init(texture: pipeInitTexture, color: UIColor.clear, size: pipeInitTexture.size())
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
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
	
	func spawnPipes(_ pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
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
		contactNode.position = CGPoint(x: pipeUp.size.width, y: self.frame.midY)
		contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.frame.size.height))
		contactNode.physicsBody?.isDynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.run(pipesMoveAndRemove)
	}
	
}
