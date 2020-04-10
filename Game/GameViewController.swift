//
//  GameViewController.swift
//  Game
//
//  Created by Seth Palmer on 3/5/20.
//  Copyright © 2020 Seth Palmer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreData
import AVFoundation

class GameViewController: UIViewController, AVAudioPlayerDelegate {

    private var music: AVAudioPlayer?
    private var musicOptions = ["Soundtrack_Moon Base","Soundtrack2_Cerulean","Soundtrack3_20XX"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        if let asset = NSDataAsset(name: musicOptions.randomElement()!){
            do{
                music = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
                music?.numberOfLoops = -1
                music?.play()
            }catch{
                print("error")
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
