//
//  WorldCreator.swift
//  Pasarica
//
//  Created by Liviu Jianu on 24/09/14.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import SpriteKit
import Foundation

class WorldCreator: SKScene {
	
	var bird = SKSpriteNode()
	
	var pipes = SKNode()
	var visibleNodes = SKNode()
	
	let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
	let birdDownTexture = SKTexture(imageNamed: "BirdDown")
	
	let groundTexture   = SKTexture(imageNamed: "Ground")
	let skylineTexture  = SKTexture(imageNamed: "Skyline")
	
	let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
	let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
	
	//Collision bit masks
	enum CollisionCategory : UInt32 {
		case Bird  = 1
		case World = 2
		case Pipe  = 4
		case Score = 8
		
		func isBitmask(bitmask : UInt32) -> Bool {
			return self == CollisionCategory.fromRaw(bitmask)
		}
	}
	
	//Scoring variables
	var scoreLabelNode = SKLabelNode()
	
	var score = 0
	var highscore : Int {
		get {
			if let high = NSUserDefaults.standardUserDefaults().objectForKey("highscore") as? Int	{
				return high
			} else {
				self.highscore = 0 // this calls the setter
				return 0
			}
		}
		set (newHighscore){
			NSUserDefaults.standardUserDefaults().setInteger(newHighscore, forKey: "highscore")
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	
	
	func createWorld() {
	//Create the Bird
	createBird(up: birdUpTexture, down: birdDownTexture)
	
	//Draw the Ground and set the limits
	drawGround(ground: groundTexture)
	
	//Draw the Sky and set the limits
	drawSky(sky: skylineTexture, ground: groundTexture)
	
	//Draw the pipes
	drawPipes(up: pipeUpTexture, down: pipeDownTexture)
	
	
	//Draw the score and high score
	drawScores()
	}
	
	func createBird(up upTexture : SKTexture, down downTexture : SKTexture) {
		
		upTexture.filteringMode = SKTextureFilteringMode.Nearest
		downTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		bird = SKSpriteNode(texture: upTexture)
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		
		
		var animation = SKAction.animateWithTextures([upTexture,downTexture], timePerFrame: 0.2)
		var flap = SKAction.repeatActionForever(animation)
		bird.runAction(flap)
		
		bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
		bird.physicsBody?.dynamic = true
		bird.physicsBody?.allowsRotation = false
		
		bird.physicsBody?.categoryBitMask = CollisionCategory.Bird.toRaw()
		bird.physicsBody?.collisionBitMask = CollisionCategory.World.toRaw() | CollisionCategory.Pipe.toRaw()
		bird.physicsBody?.contactTestBitMask = CollisionCategory.World.toRaw() | CollisionCategory.Pipe.toRaw()
		
		self.addChild(bird)
	}
	
	func drawGround(ground groundTexture : SKTexture) {
		groundTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * groundTexture.size().width))
		var resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
		var moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
		
		for var i: CGFloat = 0; i<2 + self.frame.size.width / (groundTexture.size().width); ++i {
			var sprite = SKSpriteNode(texture: groundTexture)
			sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
			sprite.runAction(moveGroundSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Ground - lower screen limit
		var groundLimit = SKNode()
		groundLimit.position = CGPointMake(0, groundTexture.size().height / 2)
		groundLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height))
		groundLimit.physicsBody?.dynamic = false
		groundLimit.physicsBody?.categoryBitMask = CollisionCategory.World.toRaw()
		self.addChild(groundLimit)
		
	}
	
	func drawSky(sky skylineTexture:SKTexture, ground groundTexture : SKTexture) {
		skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
		
		var moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * skylineTexture.size().width))
		var resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0.0)
		var moveSkylineSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
		
		for var i: CGFloat = 0; i<2 + self.frame.size.width / (skylineTexture.size().width); ++i {
			var sprite = SKSpriteNode(texture: skylineTexture)
			sprite.zPosition = -20
			sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height)
			sprite.runAction(moveSkylineSpritesForever)
			visibleNodes.addChild(sprite)
		}
		
		//Sky - upper screen limit
		var skyLimit = SKNode()
		skyLimit.position = CGPointMake(0, self.frame.size.height)
		skyLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1.0))
		skyLimit.physicsBody?.categoryBitMask = CollisionCategory.World.toRaw()
		skyLimit.physicsBody?.dynamic = false
		
		self.addChild(skyLimit)
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
		pipeDown.physicsBody?.categoryBitMask = CollisionCategory.Pipe.toRaw()
		pipeDown.physicsBody?.contactTestBitMask = CollisionCategory.Bird.toRaw()
		
		pipePair.addChild(pipeDown)
		
		let pipeUp = SKSpriteNode(texture: pipeUpTexture)
		pipeUp.position = CGPointMake(0.0, CGFloat(y))
		
		pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
		pipeUp.physicsBody?.dynamic = false
		pipeUp.physicsBody?.categoryBitMask = CollisionCategory.Pipe.toRaw()
		pipeUp.physicsBody?.contactTestBitMask = CollisionCategory.Bird.toRaw()
		pipePair.addChild(pipeUp)
		
		var contactNode = SKNode()
		contactNode.position = CGPointMake(pipeUp.size.width + bird.size.width / 2, CGRectGetMidY(self.frame))
		contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
		contactNode.physicsBody?.dynamic = false
		contactNode.physicsBody?.categoryBitMask = CollisionCategory.Score.toRaw()
		contactNode.physicsBody?.contactTestBitMask = CollisionCategory.Bird.toRaw()
		pipePair.addChild(contactNode)
		
		
		pipePair.runAction(pipesMoveAndRemove)
		pipes.addChild(pipePair)
		
	}
	
	
	func drawScores() {
		scoreLabelNode.fontName = "Helvetica-Bold"
		scoreLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 6)
		scoreLabelNode.fontSize = 600
		scoreLabelNode.alpha = 0.2
		scoreLabelNode.zPosition = -30
		scoreLabelNode.text = "\(score)"
		self.addChild(scoreLabelNode)
		
		let highScoreLabelNode = SKLabelNode()
		
		highScoreLabelNode.fontName = "Helvetica"
		highScoreLabelNode.fontSize = 20
		highScoreLabelNode.position = CGPointMake(self.frame.width - 400.0 , self.frame.height - highScoreLabelNode.fontSize)
		
		highScoreLabelNode.alpha = 0.5
		highScoreLabelNode.zPosition = -30
		
		highScoreLabelNode.text = "record: " + "\(self.highscore)"
		self.addChild(highScoreLabelNode)
	}
	
}