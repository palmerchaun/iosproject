//
//  ViewController.swift
//  Game
//
//  Created by Abby Allen on 4/3/20.
//  Copyright © 2020 Seth Palmer. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    private var menuMainSoundTrack: AVAudioPlayer?
    private var menuMainPressButton: AVAudioPlayer?
    
    @IBOutlet weak var resume: UIButton!
    var score = 10
    var fuel = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resume.isEnabled = false
        
        if let asset = NSDataAsset(name:"Main_menu_Fetch Quest"){
            do{
                menuMainSoundTrack = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
                menuMainSoundTrack?.numberOfLoops = -1
                menuMainSoundTrack?.play()
            }catch{
                print("error")
            }
        }
        if let asset = NSDataAsset(name:"menu_confirm_2_reverb"){
            do{
                menuMainPressButton = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
            }catch{
                print("error")
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue){}
    
    @IBAction func newGamePressed(_ sender: Any) {
        menuMainSoundTrack?.stop()
        menuMainPressButton?.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue2" {
            let dest = segue.destination as! GameViewController
            dest.scoreNum = score;
            dest.fuel = fuel
            //add fuel level and maybe damage level
        }
        else{
            let dest = segue.destination as! GameViewController
            dest.scoreNum = score;
        }
    }
}
