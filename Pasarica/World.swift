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
		pipes.drawPipes(completion: { (action, actionName) in
			self.gameScene.run(action, withKey: actionName)
		})
		
		self.addChild(pipes)
	}
	
	internal func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.nearest
		
		let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: TimeInterval(0.01 * groundTexture.size().width))
		let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
		let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		for i in 0...3 {
			let groundNode = SKSpriteNode(texture: groundTexture)
			groundNode.name = "Ground"
			groundNode.position = CGPoint(x: CGFloat(i) * groundNode.size.width, y: groundNode.size.height / 2)
			groundNode.run(moveGroundSpritesForever)
			self.addChild(groundNode)
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
		for i in 0...3 {
			let skylineNode = SKSpriteNode(texture: skylineTexture)
			skylineNode.zPosition = -20
			skylineNode.name = "Skyline"
			skylineNode.position = CGPoint(x: CGFloat(i) * skylineNode.size.width, y: skylineNode.size.height / 2 + groundTexture.size().height)
			skylineNode.run(moveSkylineSpritesForever)
			self.addChild(skylineNode)
		}
		
		//Sky - upper screen limit
		let skyLimit = SKNode()
		skyLimit.position = CGPoint(x: 0, y: self.gameScene.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.gameScene.frame.size.width, height: 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.world.rawValue
		skyLimit.physicsBody?.isDynamic = false
		
		self.gameScene.addChild(skyLimit)
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
		self.pipes.drawPipes(completion: { (action, actionName) in
			self.gameScene.run(action, withKey: actionName)
		})
	}
	
	func isWorldMoving() -> Bool {
		return self.speed > 0
	}
	
	func resetWorld() {
		pipes.removeAllChildren()
	}
	
}
