//
//  Pipes.swift
//  Pasarica
//
//  Created by Liviu Jianu on 21/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit

class Pipes {
	
	let pipeNodes = SKNode()
	let gameScene: GameScene
	
	let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
	let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
	
	init(gameScene: GameScene) {
		self.gameScene = gameScene
	}
	
	func drawPipes() {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.nearest
		
		//movement of pipes
		let distanceToMove = CGFloat(self.gameScene.frame.size.width + 2.0 * self.pipeUpTexture.size().width)
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
		self.gameScene.run(spawnThenDelayForever, withKey: "spawnPipesThenDelayForeverAction")
	}
	
	func spawnPipes(_ pipesMoveAndRemove : SKAction) {
		let pipeGap : CGFloat = 130.0
		let pipePair = SKNode()
		pipePair.position = CGPoint(x: self.gameScene.frame.size.width + pipeUpTexture.size().width * 2.0, y: 0)
		pipePair.zPosition = -10
		
		let height = UInt32(self.gameScene.frame.height / 3)
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
		contactNode.position = CGPoint(x: pipeUp.size.width, y: self.gameScene.frame.midY)
		contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.gameScene.frame.size.height))
		contactNode.physicsBody?.isDynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.run(pipesMoveAndRemove)
		pipeNodes.addChild(pipePair)
		
	}
	
	func pauseSpawning(pause: Bool) {
		pipeNodes.isPaused = pause
	}
	
}
