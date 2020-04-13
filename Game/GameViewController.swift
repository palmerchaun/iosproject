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

    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var greenFuel: UIButton!
    @IBOutlet weak var lightGreenFuel: UIButton!
    @IBOutlet weak var yellowFuel: UIButton!
    @IBOutlet weak var orangeFuel: UIButton!
    @IBOutlet weak var redFuel: UIButton!
    
    @IBOutlet weak var redDamage: UIButton!
    @IBOutlet weak var orangeDamage: UIButton!
    @IBOutlet weak var yellowDamage: UIButton!
    @IBOutlet weak var lightGreenDamage: UIButton!
    @IBOutlet weak var greenDamage: UIButton!
    
    @IBOutlet weak var gameOver: UILabel!
    @IBOutlet weak var finalScore: UILabel!
    @IBOutlet weak var quit: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var music: AVAudioPlayer?
    private var musicOptions = ["Soundtrack_Moon Base","Soundtrack2_Cerulean","Soundtrack3_20XX"]
    private var gameScene: GameScene?
    var isSavedGame = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        score?.text = String(0)
        
        pauseButton?.isEnabled = true
        gameOver?.isHidden = true
        finalScore?.isHidden = true
        quit?.isHidden = true
        quit?.isEnabled = false
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.viewController = self
                gameScene = scene
                
                if isSavedGame{
                    scene.isSavedGame = true
                }
                // Present the scene
                view.presentScene(scene)
            }
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
        if let view = self.view as! SKView? {
            view.isPaused = true

            let alert = UIAlertController(title: "Paused", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Home", style: .default, handler: {(action: UIAlertAction!) in self.back()}))
            alert.addAction(UIAlertAction(title: "Resume", style: .default, handler: {(action: UIAlertAction!) in view.isPaused = false}))
            self.present(alert, animated: true)
        }
    }
    
    func over(){
        pauseButton?.isEnabled = false
        gameOver?.isHidden = false
        finalScore?.isHidden = false
        finalScore?.text = "Final Score: " + (score?.text ?? "0")
        quit?.isHidden = false
        quit?.isEnabled = true
    }
    
    func back(){
        /*
         save current game
        */
        gameScene?.endGame(gameOver: false)
        music?.stop()
        //stop animation
        self.performSegue(withIdentifier: "unwindHome", sender: self)
    }
    
    func checkSavedGame(){
        gameScene!.isSavedGame = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ViewController
        //save data
        dest.resume?.isEnabled = true
        
        if segue.identifier == "quit"{
            dest.resume?.isEnabled = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
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
