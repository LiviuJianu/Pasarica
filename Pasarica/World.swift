//
//  WorldCreator.swift
//  Pasarica
//
//  Created by Liviu Jianu on 24/09/14.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import SpriteKit
import Foundation

class World {
	
	internal let gameScene : GameScene;
	
	internal let pipes = SKNode()
	internal let visibleNodes = SKNode()
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	
	init(gameScene : GameScene) {
		self.gameScene = gameScene;
		createWorld()
	}
	
	//MARK: Creating the world
	
	internal func createWorld()  {

		
		let groundTexture   = SKTexture(imageNamed: "Ground")
		let skylineTexture  = SKTexture(imageNamed: "Skyline")
		
		let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
		let pipeDownTexture = SKTexture(imageNamed: "PipeDown")

	
		//Draw the Ground and set the limits
		drawGround(ground: groundTexture)
	
		//Draw the Sky and set the limits
		drawSky(sky: skylineTexture, ground: groundTexture)
	
		//Draw the pipes
		drawPipes(up: pipeUpTexture, down: pipeDownTexture)
	
		//Draw the score and high score
		drawScores()
		
		self.gameScene.addChild(visibleNodes)
		visibleNodes.addChild(pipes)
	}
	
	internal func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * groundTexture.size().width))
		let resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
		let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		var i : CGFloat = 0
		while i < 2 + self.gameScene.frame.size.width / (groundTexture.size().width) {
			++i
			let sprite = SKSpriteNode(texture: groundTexture)
			sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
			sprite.runAction(moveGroundSpritesForever)
			visibleNodes.addChild(sprite)
			
		}
		
		//Ground - lower screen limit
		let groundLimit = SKNode()
		groundLimit.position = CGPointMake(0, groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.gameScene.frame.size.width, groundTexture.size().height))
		groundLimit.physicsBody?.dynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.World.rawValue
		self.gameScene.addChild(groundLimit)
		
	}
	
	internal func drawSky(sky skylineTexture:SKTexture, ground groundTexture : SKTexture) {
		skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		let moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * skylineTexture.size().width))
		let resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0.0)
		let moveSkylineSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		var j : CGFloat = 0
		while j < 2 + self.gameScene.frame.size.width / (skylineTexture.size().width) {
			++j;
			let sprite = SKSpriteNode(texture: skylineTexture)
			sprite.zPosition = -20
			sprite.position = CGPointMake(j * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height)
			sprite.runAction(moveSkylineSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPointMake(0, self.gameScene.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.gameScene.frame.size.width, 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.World.rawValue
		skyLimit.physicsBody?.dynamic = false
		
		self.gameScene.addChild(skyLimit)
	}
	
	internal func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.Nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		//movement of pipes
		let distanceToMove = CGFloat(self.gameScene.frame.size.width + 2.0 * pipeUpTexture.size().width)
		let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
		let removePipes = SKAction.removeFromParent()
		
		let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
		let pipeGap : CGFloat = 130.0
		
		//Spawn Pipes
		let spawn = SKAction.runBlock({() in self.spawnPipes(pipesMoveAndRemove, gap: pipeGap, upTexture: pipeUpTexture, downTexture: pipeDownTexture)})
		let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
		let spawnThenDelay = SKAction.sequence([spawn,delay])
		let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
		
		self.gameScene.runAction(spawnThenDelayForever)
	}
	
	internal func spawnPipes(pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
		let pipePair = SKNode()
		pipePair.position = CGPointMake(self.gameScene.frame.size.width + pipeUpTexture.size().width * 2.0, 0)
		pipePair.zPosition = -10
		
		let height = UInt32(self.gameScene.frame.height / 3)
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
		contactNode.position = CGPointMake(pipeUp.size.width, CGRectGetMidY(self.gameScene.frame))
		contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.gameScene.frame.size.height))
		contactNode.physicsBody?.dynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.Score.rawValue
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.Bird.rawValue
		pipePair.addChild(contactNode)
		
		
		pipePair.runAction(pipesMoveAndRemove)
		pipes.addChild(pipePair)
		
	}
	
	
	internal func drawScores() {
		scoreLabelNode.fontName = "Helvetica-Bold"
		scoreLabelNode.position = CGPointMake(CGRectGetMidX(self.gameScene.frame), self.gameScene.frame.height / 6)
		scoreLabelNode.fontSize = 400
		scoreLabelNode.alpha = 0.2
		scoreLabelNode.zPosition = -30
		scoreLabelNode.text = "0"
		self.gameScene.addChild(scoreLabelNode)
		
		highScoreLabelNode.fontName = "Helvetica"
		highScoreLabelNode.fontSize = 20
		highScoreLabelNode.position = CGPointMake(self.gameScene.frame.width - 400.0 , self.gameScene.frame.height - highScoreLabelNode.fontSize)
		
		highScoreLabelNode.alpha = 0.5
		highScoreLabelNode.zPosition = -30

		highScoreLabelNode.text = "N/A"

		self.gameScene.addChild(highScoreLabelNode)
	}
	
	//MARK: App methods
	
	func stopWorld(){
		visibleNodes.speed = 0
	}
	
	func startWorld(){
		visibleNodes.speed = 1
	}
	
	func isWorldMoving() -> Bool {
		return visibleNodes.speed > 0
	}
	
	func resetWorld() {
		pipes.removeAllChildren()
	}
	
	func setHighscore(highscore : Int) {
		highScoreLabelNode.text = "record: " + "\(highscore)"
	}
	
	func setScore(score : Int) {
		scoreLabelNode.text = "\(score)"
	}
	
}