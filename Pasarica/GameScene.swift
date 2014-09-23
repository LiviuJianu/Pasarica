// This code has not been tampered with at the request of the NSA. 
// No order under Section 215 of the USA Patriot Act has been given.
// We would expect to challenge such an order if served on us.

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	//MARK: Game variables
	var bird = SKSpriteNode()
	
	var pipes = SKNode()
	var visibleNodes = SKNode()
	
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
	
	let gameplayDict : NSDictionary = {
		let path = NSBundle.mainBundle().pathForResource("Gameplay", ofType: "plist")
		let dict = NSDictionary(contentsOfFile: path!)
		return dict
		}()
	
	//Restart game if bird collided
	var canRestart = false
	
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
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	
	//MARK: Scene setup
	// Called immediately after a scene is presented by a view.
	//This method is intended to be overridden in a subclass. You can use this method to implement any custom behavior for your scene when it is about to be presented by a view. For example, you might use this method to create the scene’s contents.
	
	override func didMoveToView(view: SKView) {

		self.addChild(visibleNodes)
		visibleNodes.addChild(pipes)
		
		self.setBackgroundColorSky()
		
		//Physics
		let gravity = gameplayDict.valueForKey("Gravity") as CGFloat
		
		self.physicsWorld.gravity = CGVectorMake(0.0, gravity);
		self.physicsWorld.contactDelegate = self
		
		let birdUpTexture   = SKTexture(imageNamed: "BirdUp")
		let birdDownTexture = SKTexture(imageNamed: "BirdDown")

		let groundTexture   = SKTexture(imageNamed: "Ground")
		let skylineTexture  = SKTexture(imageNamed: "Skyline")

		let pipeUpTexture   = SKTexture(imageNamed: "PipeUp")
		let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
		
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

	//MARK: Updating
	// Performs any scene-specific updates that need to occur before scene actions are evaluated.
	// Do not call this method directly; it is called exactly once per frame, so long as the scene is presented in a view and is not paused. By default, this method does nothing. Your scene subclass should override this method and perform any necessary updates to the scene.
	

	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		
		if(visibleNodes.speed > 0) {
			if var birdVelocity = bird.physicsBody?.velocity.dy {
				
				var rotation : CGFloat = 0
				
				if (birdVelocity < 0.0){
					rotation = birdVelocity * 0.003;
				}
				else {
					rotation = birdVelocity * 0.001;
				}

				rotation = max(-1, min(0.5, rotation))
				
				bird.zRotation = rotation
			}
		}
	}
	
	//MARK: User Interaction
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		
		if(visibleNodes.speed > 0) {
			
			bird.physicsBody?.velocity = CGVectorMake(0, 0)
			
			let impulse = CGVectorFromString(gameplayDict.valueForKey("Impulse-Vector") as String)
			bird.physicsBody?.applyImpulse(impulse)
			
		} else if(canRestart) {
			self.resetScene()
		}
	}
	
	func resetScene() {
		bird.physicsBody?.velocity = CGVectorMake(0, 0)
		bird.physicsBody?.collisionBitMask = CollisionCategory.World.toRaw() | CollisionCategory.Pipe.toRaw()

		if bird.actionForKey("stopBirdAction") != nil {
			bird.removeActionForKey("stopBirdAction")
		}
		
		let birdProps = SKAction.runBlock({() in self.resetBird()})
		bird.runAction(birdProps, completion: {() in print("Finished running starting bird")})
		
		pipes.removeAllChildren()
		
		canRestart = false
		
		visibleNodes.speed = 1
		
		score = 0
		scoreLabelNode.text = "\(score)"
	}
	
	func resetBird() {
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		bird.speed = 1.0
		bird.zRotation = 0.0
	}
	//MARK: Contact detection - SKPhysicsContactDelegate
	
	// Called when two bodies first contact each other.
	func didBeginContact(contact: SKPhysicsContact) {
		
		if(visibleNodes.speed > 0) {
			
			if(CollisionCategory.Score.isBitmask(contact.bodyA.categoryBitMask) || CollisionCategory.Score.isBitmask(contact.bodyB.categoryBitMask)) {

				score++
				scoreLabelNode.text = "\(score)"
				
				self.highscore = max(score, self.highscore);
			} else if (contact.bodyA.node == bird || contact.bodyB.node == bird) {
				
				visibleNodes.speed = 0
				bird.physicsBody?.collisionBitMask = CollisionCategory.World.toRaw()
				
				var rotateBird = SKAction.rotateByAngle(0.01, duration: 0.003)
				var stopBird = SKAction.runBlock({() in self.stopBirdFlight()})
				var birdSequence = SKAction.sequence([rotateBird,stopBird])
				bird.runAction(birdSequence, withKey: "stopBirdAction")
				
				self.removeActionForKey("flash")
				var turnBackgroundRed = SKAction.runBlock({() in self.setBackgroundRed()})
				var wait = SKAction.waitForDuration(0.05)
				var turnBackgroundWhite = SKAction.runBlock({() in self.setBackgroundColorWhite()})
				var turnBackgoundColorSky = SKAction.runBlock({() in self.setBackgroundColorSky()})
				
				var sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgoundColorSky])
				var repeatSequence = SKAction.repeatAction(sequenceOfActions, count: 4)
				var canRestartAction = SKAction.runBlock({() in self.letItRestart()})
				var groupOfActions = SKAction.group([repeatSequence, canRestartAction])
				
				self.runAction(groupOfActions, withKey:"flash")
				
			}
		}
	}
	
	func stopBirdFlight() {
		bird.speed = 0
	}
	
	func setBackgroundRed() {
		self.backgroundColor = UIColor.redColor()
	}
	func setBackgroundColorWhite() {
		self.backgroundColor = UIColor.whiteColor()
	}
	func setBackgroundColorSky() {
		self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
	}
	
	func letItRestart() {
		canRestart = true
	}
}
