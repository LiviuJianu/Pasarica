// This code has not been tampered with at the request of the NSA. 
// No order under Section 215 of the USA Patriot Act has been given.
// We would expect to challenge such an order if served on us.

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	//MARK: Game variables
	var bird = SKSpriteNode()
	
	var pipes = SKNode()
	var visibleNodes = SKNode()
	
	//Sound variables
	var birdHasScoredSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "mp3")!)
	var birdAudioPlayer = AVAudioPlayer()
	
	var gameOverSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pass", ofType: "mp3")!)
	var gameOverAudioPlayer = AVAudioPlayer()
	
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
		
		birdAudioPlayer = AVAudioPlayer(contentsOfURL: birdHasScoredSound, error: nil)
		birdAudioPlayer.prepareToPlay()

		gameOverAudioPlayer = AVAudioPlayer(contentsOfURL: gameOverSound, error: nil)
		gameOverAudioPlayer.prepareToPlay()
		
		self.setBackgroundColorSky()
		
		let worldCreator = WorldCreator(gameScene: self)
		
		self.bird  = worldCreator.bird
		self.pipes = worldCreator.pipes
		self.visibleNodes = worldCreator.visibleNodes
		self.scoreLabelNode = worldCreator.scoreLabelNode

		//Physics
		let gravity = gameplayDict.valueForKey("Gravity") as CGFloat
		
		self.physicsWorld.gravity = CGVectorMake(0.0, gravity);
		self.physicsWorld.contactDelegate = self

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
		if (shouldScoreBeIncreased(contact)){
			increaseScore();
		}
		else if (shouldGameBeTerminated(contact)){
			terminateGame();
		}
	}
	
	internal func shouldScoreBeIncreased(contact : SKPhysicsContact) -> Bool {
		if(visibleNodes.speed > 0) {
			if(CollisionCategory.Score.isBitmask(contact.bodyA.categoryBitMask) || CollisionCategory.Score.isBitmask(contact.bodyB.categoryBitMask)) {
				return true;
			}
		}
		return false;
	}
	
	internal func increaseScore(){
		score++
		scoreLabelNode.text = "\(score)"
		birdAudioPlayer.play()
		self.highscore = max(score, self.highscore);
	}
	
	internal func shouldGameBeTerminated(contact : SKPhysicsContact) -> Bool {
		if(visibleNodes.speed > 0) {
			if(contact.bodyA.node == bird || contact.bodyB.node == bird) {
				return true;
			}
		}
		return false;
	}
	
	internal func terminateGame(){
		gameOverAudioPlayer.play()
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
