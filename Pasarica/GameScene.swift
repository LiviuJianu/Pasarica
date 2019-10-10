// This code has not been tampered with at the request of the NSA.
// No order under Section 215 of the USA Patriot Act has been given.
// We would expect to challenge such an order if served on us.

import SpriteKit
import AVFoundation
import Crashlytics
import FirebaseAnalytics

class GameScene: SKScene {
	
	//MARK: Game variables
	var world : World?
	
	//Sound variables
	var birdHasScoredSound = SKAction.playSoundFileNamed("pass.mp3", waitForCompletion: false)
	var gameOverSound = SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false)
	
	//Scoring variables
	internal let scoreLabelNode = SKLabelNode()
	internal let highScoreLabelNode = SKLabelNode()
	
	var replayButton: SKLabelNode!
	var pauseButton = SKSpriteNode()	
	
	//Restart game if bird collided
	var canRestart = false
	
	//Scoring variables
	var score : Int = 0 {
		didSet {
			scoreLabelNode.text = "\(score)"
		}
	}
	var highscore : Int = 0 {
        didSet {
            highScoreLabelNode.text = "record: " + "\(highscore)"
            UserDefaults.standard.set(highscore, forKey: "highscore")
        }
	}
	
	override init(size: CGSize) {
		super.init(size: size)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	//MARK: Scene setup
	// Called immediately after a scene is presented by a view.
	//This method is intended to be overridden in a subclass. You can use this method to implement any custom behavior for your scene when it is about to be presented by a view. For example, you might use this method to create the scene’s contents.
	
	override func didMove(to view: SKView) {
		// set value of the highscore to the saved one, if any
		if let high = UserDefaults.standard.object(forKey: "highscore") as? Int	{
			highscore = high
		}
		
		self.setBackgroundColorSky()
		self.world = World(gameScene: self)
		self.addChild(self.world!)
		
		//Draw the score and high score
		addScores()
		
		//show the pause button on screen
		addPauseButton()
		
		addGravityAndInteraction()

	}

	override func update(_ currentTime: TimeInterval) {
		if(world!.isMoving()) {
			world!.update()
		}
	}
	
	//MARK: User Interaction
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if canRestart {
			self.restartGame()
		} else {
			world?.bird.flyBird()
			guard let touch = touches.first else { return }
			
			let touchLocation = touch.location(in: self)
			
			if(self.pauseButton.contains(touchLocation)) {
				if self.isPaused == false {
					pauseGame()
				} else {
					resumeGame()
				}
			}
		}
	}
	
	func pauseGame() {
		self.isPaused = true
		self.speed = 0
		
		self.pauseButton.texture = SKTexture(imageNamed: "play")

		Analytics.logEvent("pause", parameters: [
			AnalyticsParameterScore: "\(score)"
		])
		
	}
	
	func resumeGame() {
		self.isPaused = false
		self.speed = 1
		
		self.pauseButton.texture = SKTexture(imageNamed: "pause")

		Analytics.logEvent("resume", parameters: [
			AnalyticsParameterScore: "\(score)"
		])
		
	}
	

	func addGravityAndInteraction() {	
		let gameplayDict : NSDictionary = {
			let path = Bundle.main.path(forResource: "Gameplay", ofType: "plist")
			let dict = NSDictionary(contentsOfFile: path!)
			return dict!
		}()
		
		let gravity = gameplayDict.value(forKey: "Gravity") as! CGFloat
		self.physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity);
		self.physicsWorld.contactDelegate = self
	}
	
	func restartGame() {
		Analytics.logEvent("restart", parameters: nil)
		
		score = 0
		canRestart = false
		
		self.addPauseButton()
		//Will start a new game - remove the Replay button from the screen
		self.replayButton.removeFromParent()

		
		world!.resetWorld()
		world!.startWorld()
		
	}
	
	func addReplayButton() {
		// Replay Button
		replayButton = SKLabelNode(fontNamed: "Helvetica")
		replayButton.name = "Replay"
		replayButton.text = "joc nou"
		replayButton.position =  CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.65)
		replayButton.fontSize = 96
		replayButton.fontColor = SKColor.red
		self.addChild(replayButton)
	}
	
	func addPauseButton() {
		pauseButton = SKSpriteNode(imageNamed: "pause")
		pauseButton.name = "Pause"
		pauseButton.size = CGSize(width: 40, height: 40)
		pauseButton.position = CGPoint(x: self.frame.width * 0.9, y: pauseButton.frame.height)
		pauseButton.zPosition = 100
		self.addChild(pauseButton)
	}
	
	internal func addScores() {
		addScoreLabel()
		addHighscoreLabel()
	}
	
	func addScoreLabel() {
		scoreLabelNode.fontName = "Helvetica-Bold"
		scoreLabelNode.fontSize = 280
		scoreLabelNode.position = CGPoint(x: self.frame.midX, y: self.frame.height / 6)
		
		scoreLabelNode.alpha = 0.2
		scoreLabelNode.zPosition = -30
		
		scoreLabelNode.text = "\(score)"
		scoreLabelNode.name = "Score"
		self.addChild(scoreLabelNode)
	}
	
	func addHighscoreLabel() {
		highScoreLabelNode.fontName = "Helvetica"
		highScoreLabelNode.fontSize = 20
		highScoreLabelNode.position = CGPoint(x: self.frame.width * 0.87 , y: self.frame.maxY - highScoreLabelNode.fontSize * 3)
		
		highScoreLabelNode.alpha = 0.5
		
		highScoreLabelNode.text = "record: \(self.highscore)"
		highScoreLabelNode.name = "Highscore"
		self.addChild(highScoreLabelNode)
	}
	
	func flashBackground() {
		self.removeAction(forKey: "flash")
		let turnBackgroundRed = SKAction.run({() in self.setBackgroundRed()})
		let wait = SKAction.wait(forDuration: 0.05)
		let turnBackgroundWhite = SKAction.run({() in self.setBackgroundColorWhite()})
		let turnBackgoundColorSky = SKAction.run({() in self.setBackgroundColorSky()})
		
		let sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgoundColorSky])
		let repeatSequence = SKAction.repeat(sequenceOfActions, count: 4)
		self.run(repeatSequence, withKey: "flash")
	}
	
	func setBackgroundRed() {
		self.backgroundColor = UIColor.red
	}
	func setBackgroundColorWhite() {
		self.backgroundColor = UIColor.white
	}
	func setBackgroundColorSky() {
		self.backgroundColor = SKColor(red: 0/255.0, green: 194.0/255.0, blue: 201.0/255.0, alpha: 1.0)
	}
	
}

extension GameScene: SKPhysicsContactDelegate {
	// Called when two bodies first contact each other.
	func didBegin(_ contact: SKPhysicsContact) {
		if shouldScoreBeIncreased(contact){
			increaseScore()
			run(birdHasScoredSound)
		} else if self.world!.didCollide(from: contact){
			terminateGame()
		}
	}
	
	internal func shouldScoreBeIncreased(_ contact : SKPhysicsContact) -> Bool {
		if(world!.isMoving()) {
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
		}
	}
	
	internal func terminateGame(){
		self.removeAllActions()
		
		self.world!.stopWorld();
		
		self.pauseButton.removeFromParent()
		
		canRestart = true
		
		run(gameOverSound)
		flashBackground()
		addReplayButton()
	}
}
