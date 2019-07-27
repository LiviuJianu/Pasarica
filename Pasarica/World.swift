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

		let sky = Skyline(frame: gameScene.frame)
		self.addChild(sky)
		
		//Draw the pipes
		pipes.drawPipes(completion: { (action, actionName) in
			self.gameScene.run(action, withKey: actionName)
		})
		self.addChild(pipes)
		
		let ground = Ground(frame: gameScene.frame)
		self.addChild(ground)
		
		
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
