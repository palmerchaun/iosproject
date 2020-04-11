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
}
