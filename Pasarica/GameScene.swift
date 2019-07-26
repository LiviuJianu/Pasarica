// This code has not been tampered with at the request of the NSA.
// No order under Section 215 of the USA Patriot Act has been given.
// We would expect to challenge such an order if served on us.

import SpriteKit
import AVFoundation
import Crashlytics

class GameScene: SKScene {
	
	//MARK: Game variables
	var bird = Bird()
	var world : World?
	
	//Sound variables
	var birdHasScoredSound = SKAction.playSoundFileNamed("pass.mp3", waitForCompletion: false)
	var gameOverSound = SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false)
	
	var replayButton:SKLabelNode!
	var pauseButton = SKSpriteNode()

	
	let gameplayDict : NSDictionary = {
		let path = Bundle.main.path(forResource: "Gameplay", ofType: "plist")
		let dict = NSDictionary(contentsOfFile: path!)
		return dict!
		}()
	
	
	
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
            UserDefaults.standard.set(highscore, forKey: "highscore")
            UserDefaults.standard.synchronize()
        }
	}
	
	override init(size: CGSize) {
		super.init(size: size)
		// set value of the highscore to the saved one, if any
		if let high = UserDefaults.standard.object(forKey: "highscore") as? Int	{
			highscore = high
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	//MARK: Scene setup
	// Called immediately after a scene is presented by a view.
	//This method is intended to be overridden in a subclass. You can use this method to implement any custom behavior for your scene when it is about to be presented by a view. For example, you might use this method to create the scene’s contents.
	
	override func didMove(to view: SKView) {
		
		self.setBackgroundColorSky()
		
		self.world = World(gameScene: self)
		self.world!.setHighscore(self.highscore)
		
		//show the pause button on screen
		createPauseButton()
		setupBird()
		addGravityAndInteraction()

	}

	//MARK: Updating
	// Performs any scene-specific updates that need to occur before scene actions are evaluated.
	// Do not call this method directly; it is called exactly once per frame, so long as the scene is presented in a view and is not paused. By default, this method does nothing. Your scene subclass should override this method and perform any necessary updates to the scene.
	
	override func update(_ currentTime: TimeInterval) {
		/* Called before each frame is rendered */
		if(world!.isWorldMoving()) {
			bird.update()
		}
	}
	
	//MARK: User Interaction
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if(world!.isWorldMoving()) {
			let impulse = gameplayDict.value(forKey: "Impulse-Vector") as! CGFloat
			bird.flyBird(impulse)
			if (!canRestart) {
				if let touch = touches.first{
					let touchLocation = touch.location(in: self)
					if(self.pauseButton.contains(touchLocation)) {
							if self.isPaused == false {
								Answers.logCustomEvent(withName: "Game Paused",
															   customAttributes: [
																"Score": score])
								self.isPaused = true
								self.pauseButton.texture = SKTexture(imageNamed: "play")
								self.removeAllActions()
							} else {
								self.isPaused = false
								Answers.logCustomEvent(withName: "Game Resumed",
													   customAttributes: [
														"Score": score])
								self.pauseButton.texture = SKTexture(imageNamed: "pause")
								self.world?.pipes.drawPipes(on: self)
							}
						}
					}
			}
		} else if(canRestart) {
			self.resetScene()
		}
	}
	
	func createPauseButton() {
		pauseButton = SKSpriteNode(imageNamed: "pause")
		pauseButton.size = CGSize(width: 40, height: 40)
		pauseButton.position = CGPoint(x: self.frame.width * 0.9, y: pauseButton.frame.height)
		pauseButton.zPosition = 100
		self.addChild(pauseButton)
	}
	
	
	func drawPlayLabel() {
		// Play Button
		replayButton = SKLabelNode(fontNamed: "Helvetica")
		replayButton.text = "joc nou"
		replayButton.position =  CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.65)
		replayButton.fontSize = 96
		replayButton.fontColor = SKColor.red
		self.addChild(replayButton)
	}
	
	func setupBird() {
		bird = Bird()
		bird.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.midY)
		self.addChild(bird)
	}
	
	func addGravityAndInteraction() {
		//Physics
		let gravity = gameplayDict.value(forKey: "Gravity") as! CGFloat
		self.physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity);
		self.physicsWorld.contactDelegate = self
	}
	
	func resetScene() {
		bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		bird.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue | CollisionCategory.pipe.rawValue

		if bird.action(forKey: "stopBirdAction") != nil {
			bird.removeAction(forKey: "stopBirdAction")
		}
		
		let birdProps = SKAction.run({() in self.resetBird()})
		bird.run(birdProps)
		
		world!.resetWorld()
		
		resetBird()
		
		canRestart = false
		createPauseButton()
		//CREATE HERE THE CONDITION TO START THE WORLD AFTER THE START BUTTON IS PRESSED
		self.removeChildren(in: [replayButton])

		world!.startWorld()
		
		score = 0
	}
	
	func resetBird() {
		bird.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.midY)
		bird.speed = 1.0
		bird.zRotation = 0.0
	}
	
	internal func shouldScoreBeIncreased(_ contact : SKPhysicsContact) -> Bool {
		if(world!.isWorldMoving()) {
			if(CollisionCategory.score.isBitmask(contact.bodyA.categoryBitMask) || CollisionCategory.score.isBitmask(contact.bodyB.categoryBitMask)) {
				return true;
			}
		}
		return false;
	}
	
	internal func increaseScore(){
		score += 1
		if (score > self.highscore){
			self.highscore = score
			self.world!.setHighscore(self.highscore)
		}
	}

	internal func shouldGameBeTerminated(_ contact : SKPhysicsContact) -> Bool {
		if(world!.isWorldMoving()) {
			if(contact.bodyA.node == bird || contact.bodyB.node == bird) {
				return true;
			}
		}
		return false;
	}
	
	internal func terminateGame(){

		world!.stopWorld();
		run(gameOverSound)
		
		bird.physicsBody?.collisionBitMask = CollisionCategory.world.rawValue
		
		let rotateBird = SKAction.rotate(byAngle: 0.01, duration: 0.003)
		let stopBird = SKAction.run({() in self.stopBirdFlight()})
		let birdSequence = SKAction.sequence([rotateBird,stopBird])
		bird.run(birdSequence, withKey: "stopBirdAction")
		
		self.removeAction(forKey: "flash")
		let turnBackgroundRed = SKAction.run({() in self.setBackgroundRed()})
		let wait = SKAction.wait(forDuration: 0.05)
		let turnBackgroundWhite = SKAction.run({() in self.setBackgroundColorWhite()})
		let turnBackgoundColorSky = SKAction.run({() in self.setBackgroundColorSky()})
		
		let sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgoundColorSky])
		let repeatSequence = SKAction.repeat(sequenceOfActions, count: 4)
		let canRestartAction = SKAction.run({() in self.letItRestart()})
		let groupOfActions = SKAction.group([repeatSequence, canRestartAction])
		
		self.run(groupOfActions, withKey:"flash")
	}
	
	func stopBirdFlight() {
		bird.speed = 0
	}
	
	func setBackgroundRed() {
		self.backgroundColor = UIColor.red
	}
	func setBackgroundColorWhite() {
		self.backgroundColor = UIColor.white
	}
	func setBackgroundColorSky() {
		self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
	}
	
	func letItRestart() {
		canRestart = true
	}
}

extension GameScene: SKPhysicsContactDelegate {
	// Called when two bodies first contact each other.
	func didBegin(_ contact: SKPhysicsContact) {
		if (shouldScoreBeIncreased(contact)){
			increaseScore()
			run(birdHasScoredSound)
		}
		else if (shouldGameBeTerminated(contact)){
			terminateGame()
			drawPlayLabel()
			self.pauseButton.removeFromParent()
		}
	}
}
