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
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var timetrial: UIButton!
    
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
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HighScore")
        request.returnsObjectsAsFaults = false
        
        do{
            
            let record = try context.fetch(request) as![NSManagedObject]
            
            if record.count > 0 {
                highScoreLabel.text = "\(record[0].value(forKey: "score") as! Int)"
            }
        }catch{
            print("load score failed \(error)")
        }
        
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: "PausedGame")
        request2.returnsObjectsAsFaults = false
        
        do{
            let savedGames = try context.fetch(request2) as![NSManagedObject]
            
            if savedGames.count > 0{
                resume.isEnabled = true
            }
        } catch{
            print("Couldn't load saved game \(error)")
        }
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HighScore")
        request.returnsObjectsAsFaults = false
        
        do{
            
            let record = try context.fetch(request) as![NSManagedObject]
            
            if record.count > 0 {
                highScoreLabel.text = "\(record[0].value(forKey: "score") as! Int)"
            }
        }catch{
            print("load score failed \(error)")
        }
        menuMainSoundTrack?.play()
    }
    @IBAction func resumeGamePressed(_ sender: Any) {
        menuMainSoundTrack?.stop()
        menuMainPressButton?.play()
    }
    @IBAction func newGamePressed(_ sender: Any) {
        menuMainSoundTrack?.stop()
        menuMainPressButton?.play()
    }
    @IBAction func timeTrialPressed(_ sender: Any) {
        menuMainSoundTrack?.stop()
        menuMainPressButton?.play()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! GameViewController

        if segue.identifier == "resume" {
            dest.isSavedGame = true
        }
        else if segue.identifier == "time"{
            dest.setTimer = true
        }
    }
}
