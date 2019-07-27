//
//  Pipes.swift
//  Pasarica
//
//  Created by Liviu Jianu on 21/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

class Pipes: SKNode {
	
	var gameFrame: CGRect
	
	let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
	let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
	
	init(frame: CGRect) {
		self.gameFrame = frame
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawPipes(completion: (SKAction, String) -> ()) {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.nearest
		
		//movement of pipes
		let distanceToMove = self.gameFrame.size.width + 3.0 * self.pipeUpTexture.size().width
		let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
		let removePipes = SKAction.removeFromParent()
		
		let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
		
		//Spawn Pipes
		let spawn = SKAction.run({() in self.spawnPipes(pipesMoveAndRemove)})
		let delay = SKAction.wait(forDuration: TimeInterval(2.0))
		let spawnThenDelay = SKAction.sequence([spawn,delay])
		let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
		// When Creating Pipes, this will make pipes indefinitely when the player died
		// We need to fix this
		// For the moment we just remove all the actions from the game scene and restart
		// drawing pipes when a new game is started
		completion(spawnThenDelayForever, "spawnPipesThenDelayForeverAction")
	}
	
	func spawnPipes(_ pipesMoveAndRemove : SKAction) {
		let pipeGap : CGFloat = 130.0
		let pipePair = SKNode()
		pipePair.name = "PipePair"
		pipePair.position = CGPoint(x: self.gameFrame.size.width + pipeUpTexture.size().width * 2.0, y: 0)
		pipePair.zPosition = -10
		
		let height = UInt32(self.gameFrame.height / 3)
		let y = arc4random() % height
		
		let pipeDown = SKSpriteNode(texture: pipeDownTexture)
		pipeDown.name = "PipeDown"
		pipeDown.position = CGPoint(x: 0.0, y: CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
		
		pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
		pipeDown.physicsBody?.isDynamic = false
		pipeDown.physicsBody?.categoryBitMask = CollisionCategory.pipe.rawValue
		pipeDown.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		
		pipePair.addChild(pipeDown)
		
		let pipeUp = SKSpriteNode(texture: pipeUpTexture)
		pipeUp.name = "PipeUp"
		pipeUp.position = CGPoint(x: 0.0, y: CGFloat(y))
		
		pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
		pipeUp.physicsBody?.isDynamic = false
		pipeUp.physicsBody?.categoryBitMask = CollisionCategory.pipe.rawValue
		pipeUp.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(pipeUp)
		
		let contactNode = SKNode()
		contactNode.position = CGPoint(x: pipeUp.size.width, y: self.gameFrame.midY)
		contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.gameFrame.size.height))
		contactNode.physicsBody?.isDynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.run(pipesMoveAndRemove)
		self.addChild(pipePair)
		
	}
	
	
}
