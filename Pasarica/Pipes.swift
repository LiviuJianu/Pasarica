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
		self.init(texture: pipeInitTexture, color: UIColor.clearColor(), size: pipeInitTexture.size())
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
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
	
	func spawnPipes(pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
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
		
		let contactNode = SKNode()
		contactNode.position = CGPointMake(pipeUp.size.width, CGRectGetMidY(self.frame))
		contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
		contactNode.physicsBody?.dynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.Score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.Bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.runAction(pipesMoveAndRemove)
	}
	
}
