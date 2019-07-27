//
//  MenuScene.swift
//  Pasarica
//
//  Created by Liviu Jianu on 18/01/15.
//  Copyright (c) 2015 Liviu Jianu. All rights reserved.
//

import SpriteKit
import AVFoundation

class MenuScene: SKScene, AVAudioPlayerDelegate {
	
	var playButton:SKLabelNode!
	var bounceTimer:Timer!
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	
	

	override func didMove(to view: SKView) {
		createBackground()
		
		bounceTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(MenuScene.animatePlay), userInfo: nil, repeats: true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		if let touch = touches.first{
			
			let touchLocation = touch.location(in: self)
			
			if (playButton.contains(touchLocation)) {
				self.switchToPlay()
			}
		}
	}
	
	
	func createBackground() {
		drawGameLabel()
		drawPlayLabel()
		
		//Create the Bird
		self.addChild(Bird(frame: self.frame))
	}

	func drawGameLabel() {
		// Game Label
		let gameLabel = SKLabelNode(fontNamed: "Helvetica")
		gameLabel.text = "pasarica"
		gameLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
		gameLabel.fontSize = 72
		gameLabel.fontColor = SKColor.white
		gameLabel.zPosition = 100
		gameLabel.name = "GameLabel"
		self.addChild(gameLabel)
	}
	
	func drawPlayLabel() {
		// Play Button
		playButton = SKLabelNode(fontNamed: "Helvetica")
		playButton.text = "joaca"
		playButton.position =  CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.65)
		playButton.fontSize = 96
		playButton.fontColor = SKColor.red
		playButton.zPosition = 100
		playButton.name = "Play"
		self.addChild(playButton)
	}
	
	@objc func animatePlay () {
		let bounceLarger = SKAction.scale(to: 1.25, duration: 0.15)
		let bounceNormal = SKAction.scale(to: 1.0, duration: 0.15)
		let bounceSequence = SKAction.sequence([bounceLarger, bounceNormal])
		playButton.run(SKAction.repeat(bounceSequence, count: 3))
	}
	
	func switchToPlay () {
		bounceTimer.invalidate()
		
		let scene = GameScene(size: view!.bounds.size)
		// Configure the view.
		let skView = view! as SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
		
		/* Set the scale mode to scale to fit the window */
		scene.scaleMode = .aspectFill
		let gameTransition = SKTransition.fade(with: SKColor.black, duration: 0.15)
		skView.presentScene(scene, transition: gameTransition)
		
	}
	
}
