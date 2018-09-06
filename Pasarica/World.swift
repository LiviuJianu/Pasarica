//
//  WorldCreator.swift
//  Pasarica
//
//  Created by Liviu Jianu on 24/09/14.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import SpriteKit
import Foundation
import Crashlytics

class World {
	
	internal let gameScene : GameScene;
	
	internal let pipes = SKNode()
	internal let visibleNodes = SKNode()
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	
	var pauseButton = SKSpriteNode()
	
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
		
		//show the pause button on screen
		createPauseButton()
		
		self.gameScene.addChild(visibleNodes)
		visibleNodes.addChild(pipes)
	}
	
	internal func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: TimeInterval(0.01 * groundTexture.size().width))
		let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
		let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		var i : CGFloat = 0
		while i < 2 + self.gameScene.frame.size.width / (groundTexture.size().width) {
			i += 1
			let sprite = SKSpriteNode(texture: groundTexture)
			sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2)
			sprite.run(moveGroundSpritesForever)
			visibleNodes.addChild(sprite)
			
		}
		
		//Ground - lower screen limit
		let groundLimit = SKNode()
		groundLimit.position = CGPoint(x: 0, y: groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.gameScene.frame.size.width, height: groundTexture.size().height))
		groundLimit.physicsBody?.isDynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		self.gameScene.addChild(groundLimit)
		
	}
	
	internal func drawSky(sky skylineTexture:SKTexture, ground groundTexture : SKTexture) {
		skylineTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveSkylineSprite = SKAction.moveBy(x: -skylineTexture.size().width, y: 0, duration: TimeInterval(0.01 * skylineTexture.size().width))
		let resetSkylineSprite = SKAction.moveBy(x: skylineTexture.size().width, y: 0, duration: 0.0)
		let moveSkylineSpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		var j : CGFloat = 0
		while j < 2 + self.gameScene.frame.size.width / (skylineTexture.size().width) {
			j += 1;
			let sprite = SKSpriteNode(texture: skylineTexture)
			sprite.zPosition = -20
			sprite.position = CGPoint(x: j * sprite.size.width, y: sprite.size.height / 2 + groundTexture.size().height)
			sprite.run(moveSkylineSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPoint(x: 0, y: self.gameScene.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.gameScene.frame.size.width, height: 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		skyLimit.physicsBody?.isDynamic = false
		
		self.gameScene.addChild(skyLimit)
	}
	
	internal func drawPipes(up pipeUpTexture:SKTexture, down pipeDownTexture:SKTexture) {
		pipeUpTexture.filteringMode = SKTextureFilteringMode.nearest
		pipeDownTexture.filteringMode = SKTextureFilteringMode.nearest
		
		//movement of pipes
		let distanceToMove = CGFloat(self.gameScene.frame.size.width + 2.0 * pipeUpTexture.size().width)
		let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
		let removePipes = SKAction.removeFromParent()
		
		let pipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
		let pipeGap : CGFloat = 130.0
		
		//Spawn Pipes
		let spawn = SKAction.run({() in self.spawnPipes(pipesMoveAndRemove, gap: pipeGap, upTexture: pipeUpTexture, downTexture: pipeDownTexture)})
		let delay = SKAction.wait(forDuration: TimeInterval(2.0))
		let spawnThenDelay = SKAction.sequence([spawn,delay])
		let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
		
		self.gameScene.run(spawnThenDelayForever)
	}
	
	internal func spawnPipes(_ pipesMoveAndRemove : SKAction, gap pipeGap : CGFloat, upTexture pipeUpTexture: SKTexture, downTexture pipeDownTexture: SKTexture) {
		
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
		pipes.addChild(pipePair)
		
	}
	
	
	internal func drawScores() {
		scoreLabelNode.fontName = "Helvetica-Bold"
		scoreLabelNode.position = CGPoint(x: self.gameScene.frame.midX, y: self.gameScene.frame.height / 6)
		scoreLabelNode.fontSize = 280
		scoreLabelNode.alpha = 0.2
		scoreLabelNode.zPosition = -30
		scoreLabelNode.text = "0"
		self.gameScene.addChild(scoreLabelNode)
		
		highScoreLabelNode.fontName = "Helvetica"
		highScoreLabelNode.fontSize = 20
		highScoreLabelNode.position = CGPoint(x: self.gameScene.frame.width - 350.0 , y: self.gameScene.frame.height - highScoreLabelNode.fontSize)
		
		highScoreLabelNode.alpha = 0.5

		highScoreLabelNode.text = "N/A"

		self.gameScene.addChild(highScoreLabelNode)
	}
	
	internal func createPauseButton() {
		pauseButton = SKSpriteNode(imageNamed: "pause")
		pauseButton.size = CGSize(width: 40, height: 40)
		pauseButton.position = CGPoint(x: self.gameScene.frame.width - 330, y: 30)
		pauseButton.zPosition = 100
		self.gameScene.addChild(pauseButton)
	}
	
	//MARK: App methods
	
	func stopWorld(){
		visibleNodes.speed = 0
		Answers.logLevelEnd("Game Over",
							score: NSNumber(integerLiteral: gameScene.score),
							success: true,
							customAttributes: nil)
		
	}
	
	func startWorld(){
		Answers.logLevelStart("Start Play",
							  customAttributes: nil)
		visibleNodes.speed = 1
	}
	
	func isWorldMoving() -> Bool {
		return visibleNodes.speed > 0
	}
	
	func resetWorld() {
		createPauseButton()
		pipes.removeAllChildren()
	}
	
	func setHighscore(_ highscore : Int) {
		highScoreLabelNode.text = "record: " + "\(highscore)"
	}
	
	func setScore(_ score : Int) {
		scoreLabelNode.text = "\(score)"
	}
	
}
