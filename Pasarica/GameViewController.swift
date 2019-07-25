//
//  GameViewController.swift
//  Pasarica
//
//  Created by Liviu Jianu on 15/09/14.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) throws -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
			let sceneData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()   
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let menuScene = MenuScene(size: view.bounds.size)
		let skView = view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		menuScene.scaleMode = .resizeFill
		
		skView.presentScene(menuScene)
    }
	
}
