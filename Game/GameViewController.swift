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
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var resume: UIButton!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var timer: UILabel!
    
    private var music: AVAudioPlayer?
    private var musicOptions = ["Soundtrack_Moon Base","Soundtrack2_Cerulean","Soundtrack3_20XX"]
    private var gameScene: GameScene?
    var isSavedGame = false
    var reason = ""
    var setTimer = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        score?.text = String(0)
        reasonLabel?.isHidden = true
        
        resume?.isHidden = true
        resume?.isEnabled = false
        
        homeButton?.isHidden = true
        homeButton?.isEnabled = false
        
        pauseButton?.isEnabled = true
        gameOver?.isHidden = true
        finalScore?.isHidden = true
        
        quit?.isHidden = true
        quit?.isEnabled = false
        
        if setTimer{
            timer?.isHidden = false
        }
        else{
            timer?.isHidden = true
        }
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.viewController = self
                gameScene = scene
                scene.timeMode = setTimer
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
            resume?.isHidden = false
            resume?.isEnabled = true
            
            homeButton?.isHidden = false
            homeButton?.isEnabled = true
            
            gameOver?.isHidden = false
            gameOver?.text = "Paused"
            
            reasonLabel?.isHidden = false
            reasonLabel?.text = "Score: " + (score?.text ?? "0")
        }
    }
    
    
    @IBAction func resume(_ sender: Any) {
        if let view = self.view as! SKView? {
            view.isPaused = false
            gameScene?.lastTime = -1.0
            resume?.isHidden = true
            resume?.isEnabled = false
            
            homeButton?.isHidden = true
            homeButton?.isEnabled = false
                   
            pauseButton?.isEnabled = true
            gameOver?.isHidden = true
            reasonLabel?.isHidden = true
                   
            quit?.isHidden = true
            quit?.isEnabled = false
            
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
    }
    
    func over(){
        pauseButton?.isEnabled = false
        gameOver?.isHidden = false
        gameOver?.text = "Game Over!"
        
        reasonLabel?.isHidden = false
        reasonLabel?.text = reason
        
        finalScore?.isHidden = false
        finalScore?.text = "Final Score: " + (score?.text ?? "0")
        
        quit?.isHidden = false
        quit?.isEnabled = true
        music?.stop()
    }
    
    func overTimed(_ timeTaken : String){
        //note: don't save data here. Do it in the GameScene class
        pauseButton?.isEnabled = false
        gameOver?.isHidden = false
        gameOver?.text = "You win!"
        
        reasonLabel?.isHidden = false
        reasonLabel?.text = ""//if we want to put like "You beat your best time" this is where we would put it
        
        finalScore?.isHidden = false
        finalScore?.text = "Time taken: " + timeTaken
        
        quit?.isHidden = false
        quit?.isEnabled = true
        music?.stop()
    }
    
    func checkSavedGame(){
        gameScene!.isSavedGame = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Home"{
            let dest = segue.destination as! ViewController
            gameScene?.endGame(gameOver: false, timedWin: false)
            music?.stop()
            dest.resume?.isEnabled = true
        }
        
        else if segue.identifier == "quit"{
            let dest = segue.destination as! ViewController
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
