// This code has not been tampered with at the request of the NSA.
// No order under Section 215 of the USA Patriot Act has been given.
// We would expect to challenge such an order if served on us.

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	//MARK: Game variables
	var bird = Bird()
	
	//Sound variables
	var birdHasScoredSound = SKAction.playSoundFileNamed("hai.mp3", waitForCompletion: false)
	var gameOverSound = SKAction.playSoundFileNamed("aa_pacat.mp3", waitForCompletion: false)
	
	var replayButton:SKLabelNode!
	
	let gameplayDict : NSDictionary = {
		let path = NSBundle.mainBundle().pathForResource("Gameplay", ofType: "plist")
		let dict = NSDictionary(contentsOfFile: path!)
		return dict!
		}()
	
	var world : World?
	
	//Restart game if bird collided
	var canRestart = false
	
	//Scoring variables
	var score : Int = 0 {
		didSet {
			self.world?.setScore(score)
		}
	}
	var highscore : Int = 0 {
        didSet {
            self.world?.setHighscore(highscore)
            NSUserDefaults.standardUserDefaults().setInteger(highscore, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        // set value of the highscore to the saved one, if any
        if let high = NSUserDefaults.standardUserDefaults().objectForKey("highscore") as? Int	{
            highscore = high
        }
	}

	func drawPlayLabel() {
		// Play Button
		replayButton = SKLabelNode(fontNamed: "Helvetica")
		replayButton.text = "joaca"
		replayButton.position =  CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.65)
		replayButton.fontSize = 96
		replayButton.fontColor = SKColor.redColor()
		replayButton.zPosition = -10
		self.addChild(replayButton)
	}
	
	//MARK: Scene setup
	// Called immediately after a scene is presented by a view.
	//This method is intended to be overridden in a subclass. You can use this method to implement any custom behavior for your scene when it is about to be presented by a view. For example, you might use this method to create the scene’s contents.
	
	override func didMoveToView(view: SKView) {
		
		self.setBackgroundColorSky()
		
		self.world = World(gameScene: self)
		self.world!.setHighscore(self.highscore)
		
		setupBird()
		addGravityAndInteraction()

	}

	//MARK: Updating
	// Performs any scene-specific updates that need to occur before scene actions are evaluated.
	// Do not call this method directly; it is called exactly once per frame, so long as the scene is presented in a view and is not paused. By default, this method does nothing. Your scene subclass should override this method and perform any necessary updates to the scene.
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if(world!.isWorldMoving()) {
			bird.update()
		}
	}
	
	//MARK: User Interaction
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		
		if(world!.isWorldMoving()) {
			let impulse = gameplayDict.valueForKey("Impulse-Vector") as CGFloat
			bird.flyBird(impulse)
		} else if(canRestart) {
			self.resetScene()
		}
	}
	
	func setupBird() {
		bird = Bird()
		bird.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		self.addChild(bird)
	}
	
	func addGravityAndInteraction() {
		//Physics
		let gravity = gameplayDict.valueForKey("Gravity") as CGFloat
		self.physicsWorld.gravity = CGVectorMake(0.0, gravity);
		self.physicsWorld.contactDelegate = self
	}
	
	func resetScene() {
		bird.physicsBody?.velocity = CGVectorMake(0, 0)
		bird.physicsBody?.collisionBitMask = CollisionCategory.World.rawValue | CollisionCategory.Pipe.rawValue

		if bird.actionForKey("stopBirdAction") != nil {
			bird.removeActionForKey("stopBirdAction")
		}
		
		let birdProps = SKAction.runBlock({() in self.resetBird()})
		bird.runAction(birdProps)
		
		world!.resetWorld()
		
		canRestart = false
		//CREATE HERE THE CONDITION TO START THE WORLD AFTER THE START BUTTON IS PRESSED
		self.removeChildrenInArray([replayButton])

		world!.startWorld()
		
		score = 0
	}
	
	func resetBird() {
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: CGRectGetMidY(self.frame))
		bird.speed = 1.0
		bird.zRotation = 0.0
	}
	//MARK: Contact detection - SKPhysicsContactDelegate

	// Called when two bodies first contact each other.
	func didBeginContact(contact: SKPhysicsContact) {
		if (shouldScoreBeIncreased(contact)){
			increaseScore();
			runAction(birdHasScoredSound)
		}
		else if (shouldGameBeTerminated(contact)){
			terminateGame();
			drawPlayLabel()
		}
	}
	
	internal func shouldScoreBeIncreased(contact : SKPhysicsContact) -> Bool {
		if(world!.isWorldMoving()) {
			if(CollisionCategory.Score.isBitmask(contact.bodyA.categoryBitMask) || CollisionCategory.Score.isBitmask(contact.bodyB.categoryBitMask)) {
				return true;
			}
		}
		return false;
	}
	
	internal func increaseScore(){
		score++
		if (score > self.highscore){
			self.highscore = score
			self.world!.setHighscore(self.highscore)
		}
	}

	internal func shouldGameBeTerminated(contact : SKPhysicsContact) -> Bool {
		if(world!.isWorldMoving()) {
			if(contact.bodyA.node == bird || contact.bodyB.node == bird) {
				return true;
			}
		}
		return false;
	}
	
	internal func terminateGame(){

		world!.stopWorld();
		runAction(gameOverSound)
		
		bird.physicsBody?.collisionBitMask = CollisionCategory.World.rawValue
		
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
