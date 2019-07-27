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

final class World: SKNode {
	
	var gameScene : GameScene
	
	var bird: Bird
	var pipes: Pipes
	
	init(gameScene : GameScene) {
		self.gameScene = gameScene
		self.pipes = Pipes(frame: gameScene.frame)
		self.bird = Bird(frame: gameScene.frame)
		
		super.init()
		
		self.name = "World"
		self.createWorld()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: Creating the world
	
	internal func createWorld()  {

		
		let sky = Skyline(frame: gameScene.frame)
		self.addChild(sky)
		
		self.addChild(pipes)
		
		
		self.addChild(bird)
		
		
		let ground = Ground(frame: gameScene.frame)
		self.addChild(ground)
		
		
	}
	
	//MARK: App methods
	func stopWorld(){
		self.speed = 0
		self.bird.stop()
		
		Answers.logLevelEnd("Game Over",
							score: NSNumber(integerLiteral: gameScene.score),
							success: true,
							customAttributes: nil)
	}
	
	func startWorld(){
		Answers.logLevelStart("Start Play",
							  customAttributes: nil)
		self.speed = 1
		self.pipes.drawPipes()
	}
	
	func isWorldMoving() -> Bool {
		return self.speed > 0
	}
	
	func resetWorld() {
		pipes.removeAllChildren()
		bird.reset()
		
	}
	
	func update() {
		self.bird.update()
	}
	
	func didCollide(from contact: SKPhysicsContact) -> Bool {
		if self.speed > 0 {
			return contact.bodyA.node == bird || contact.bodyB.node == bird
		}
		return false
	}
	
}
