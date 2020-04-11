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
    
    @IBAction func pause(_ sender: Any) {
        let alert = UIAlertController(title: "Paused", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Home", style: .default, handler: {(action: UIAlertAction!) in self.back()}))
        alert.addAction(UIAlertAction(title: "Resume", style: .default))
        self.present(alert, animated: true)
    }
    
    func back(){
        //stop animation
        self.performSegue(withIdentifier: "unwindHome", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ViewController
        //save data
        dest.resume.isEnabled = true
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
