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

class World: SKNode {
	
	var gameScene : GameScene
	
	var pipes: Pipes
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	
	init(gameScene : GameScene) {
		self.gameScene = gameScene
		self.pipes = Pipes(frame: gameScene.frame)
		
		super.init()
		self.createWorld()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: Creating the world
	
	internal func createWorld()  {

		let groundTexture   = SKTexture(imageNamed: "Ground")
		let skylineTexture  = SKTexture(imageNamed: "Skyline")
		
		//Draw the Ground and set the limits
		drawGround(ground: groundTexture)
	
		//Draw the Sky and set the limits
		drawSky(sky: skylineTexture, ground: groundTexture)
	
		//Draw the pipes
		pipes.drawPipes(on: self.gameScene)
	
		//Draw the score and high score
		drawScores()
		
		self.addChild(pipes)
		self.gameScene.addChild(self)
		
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
			self.addChild(sprite)
			
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
			self.addChild(sprite)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPoint(x: 0, y: self.gameScene.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.gameScene.frame.size.width, height: 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		skyLimit.physicsBody?.isDynamic = false
		
		self.gameScene.addChild(skyLimit)
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
		highScoreLabelNode.position = CGPoint(x: self.gameScene.frame.width * 0.87 , y: self.gameScene.frame.maxY - highScoreLabelNode.fontSize * 3)
		
		highScoreLabelNode.alpha = 0.5

		highScoreLabelNode.text = "N/A"

		self.gameScene.addChild(highScoreLabelNode)
	}
	
	//MARK: App methods
	
	func stopWorld(){
		self.speed = 0
		Answers.logLevelEnd("Game Over",
							score: NSNumber(integerLiteral: gameScene.score),
							success: true,
							customAttributes: nil)
		gameScene.removeAllActions()
	}
	
	func startWorld(){
		Answers.logLevelStart("Start Play",
							  customAttributes: nil)
		self.speed = 1
		self.pipes.drawPipes(on: self.gameScene)
	}
	
	func isWorldMoving() -> Bool {
		return self.speed > 0
	}
	
	func resetWorld() {
		pipes.removeAllChildren()
	}
	
	func setHighscore(_ highscore : Int) {
		highScoreLabelNode.text = "record: " + "\(highscore)"
	}
	
	func setScore(_ score : Int) {
		scoreLabelNode.text = "\(score)"
	}
	
}
