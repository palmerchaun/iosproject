//
//  GameScene.swift
//  Game
//
//  Created by Seth Palmer on 3/5/20.
//  Copyright © 2020 Seth Palmer. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import CoreData

class GameScene: SKScene, AVAudioPlayerDelegate {
    
    var viewController : GameViewController!
    var isSavedGame = false
    var timeMode = false
    
    private var ship : SKSpriteNode?
    private var asteroid : SKSpriteNode?
    private var fuel : SKSpriteNode?
    private var finishLine : SKShapeNode?
    private var created = false
    private var vel = 2.0
    private var moving = false
    private var thePos: CGPoint?
    private var distance: Int = 0
    private var health = 0
    private var fuelAmt = 0
    private var fuelCounter = 0
    private var timer = 0.0
    private var crashing = false
    private var reason = "You ran out of fuel!"
    
    private var soundCollect: AVAudioPlayer?
    private var soundExplode: AVAudioPlayer?
    private var soundLose: AVAudioPlayer?
    private var soundWin: AVAudioPlayer?
    
    private var timeTrialGoal = 80
    
    public var lastTime = -1.0
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        self.ship = SKSpriteNode.init(imageNamed: "ship")
        ship?.size = CGSize(width: 120, height: 200)
        self.asteroid = SKSpriteNode.init(imageNamed: "meteor")
        asteroid?.size = CGSize(width: 250, height: 160)
        self.finishLine = SKShapeNode.init(rectOf: CGSize.init(width: 650, height: 50))
        finishLine?.fillColor = UIColor.systemRed
        finishLine?.strokeColor = UIColor.systemRed
        finishLine?.position.y = 1300
        self.fuel = SKSpriteNode.init(imageNamed: "fuel")
        fuel?.size = CGSize(width: 75, height: 75)
        fuel?.position.y = -800
        if let asteroid = self.asteroid {
            asteroid.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if pos.x < ship!.position.x{
            if abs(pos.x - ship!.position.x) > 20{
                ship!.position.x -= 20
            } else{
                ship!.position.x = pos.x
            }
        } else if pos.x > ship!.position.x{
            if abs(pos.x - ship!.position.x) > 20{
                ship!.position.x += 20
            } else{
                ship!.position.x = pos.x
            }
        }
    }
    
    func moveShip(){
        if moving {
            if thePos!.x > 300{
                thePos!.x = 300
            } else if thePos!.x < -300{
                thePos!.x = -300
            }
            touchMoved(toPoint: thePos!)
        }
    }
    
    func moveAsteroid(){
        asteroid!.position.y -= CGFloat(vel)
        if(distance == timeTrialGoal - 1 && timeMode){
            finishLine!.position.y -= CGFloat(vel)
        }
        if asteroid!.position.y < -800{
            asteroid!.position.y = 800
            asteroid!.position.x = CGFloat(Int.random(in: -325...325))
            
            updateDistance()
            
            if (timeMode && distance >= timeTrialGoal){
                endGame(gameOver: true, timedWin: true)
            }
            
            fuelAmt -= 5
            fuelCounter -= 1
            if fuelCounter <= 0 {
                fuelCounter = 8
                fuel!.position.x = CGFloat(Int.random(in: -275...275))
                fuel!.position.y = 1600
            }
            if fuelAmt <= 0{
                reason = "You ran out of fuel!"
                viewController.reason = reason
                endGame(gameOver: true, timedWin: false)
            }
        }
    }
    
    func moveFuel(){
        fuel!.position.y -= CGFloat(vel)
    }
    
    func collisionDetection(){
        //for asteroids
        if abs(ship!.position.x - asteroid!.position.x) < (ship!.size.width + asteroid!.size.width) * 0.25 {
            if abs(ship!.position.y - asteroid!.position.y) < (ship!.size.height + asteroid!.size.height) * 0.4 {
                health -= 1
                soundExplode?.play()
                asteroid!.position.y = 1200
                asteroid!.position.x = CGFloat(Int.random(in: -325...325))
                updateHealthMeter()
                fuelAmt -= 5
                fuelCounter -= 1
                vel /= 2
                if vel < 2{
                    vel = 2
                }
                if fuelCounter <= 0 {
                    fuelCounter = 8
                    fuel!.position.x = CGFloat(Int.random(in: -275...275))
                    fuel!.position.y = 1600
                }
                if health == 0{
                    reason = "You took too much damage!"
                    viewController.reason = reason
                    endGame(gameOver: true, timedWin: false)
                }
            }
        }
        //for fuel
        if abs(ship!.position.x - fuel!.position.x) < (ship!.size.width + fuel!.size.width) * 0.25 {
            if abs(ship!.position.y - fuel!.position.y) < (ship!.size.height + fuel!.size.height) * 0.4 {
                fuelAmt = 100
                fuel!.position.y = -800
                soundCollect?.play()
                updateFuelMeter()
            }
        }
    }
    
    func updateDistance(){
        distance += 1
        viewController.score.text = String(distance)
    }
    
    func updateFuelMeter(){
        switch(fuelAmt){
        case 0:
            viewController.redFuel.isHidden = true
            viewController.orangeFuel.isHidden = true
            viewController.yellowFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.greenFuel.isHidden = true
        case 0...20:
            viewController.redFuel.isHidden = false
            viewController.orangeFuel.isHidden = true
            viewController.yellowFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.greenFuel.isHidden = true
        case 0...40:
            viewController.redFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.yellowFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.greenFuel.isHidden = true
        case 0...60:
            viewController.redFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.yellowFuel.isHidden = false
            viewController.lightGreenFuel.isHidden = true
            viewController.greenFuel.isHidden = true
        case 0...80:
            viewController.redFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.yellowFuel.isHidden = false
            viewController.lightGreenFuel.isHidden = false
            viewController.greenFuel.isHidden = true
        default:
            viewController.redFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.yellowFuel.isHidden = false
            viewController.lightGreenFuel.isHidden = false
            viewController.greenFuel.isHidden = false
            break
        }
    }
    func updateHealthMeter(){
        switch(health){
        case 0:
            viewController.redDamage.isHidden = true
            viewController.orangeDamage.isHidden = true
            viewController.yellowDamage.isHidden = true
            viewController.lightGreenDamage.isHidden = true
            viewController.greenDamage.isHidden = true
        case 0...1:
            viewController.redDamage.isHidden = false
            viewController.orangeDamage.isHidden = true
            viewController.yellowDamage.isHidden = true
            viewController.lightGreenDamage.isHidden = true
            viewController.greenDamage.isHidden = true
        case 0...2:
            viewController.redDamage.isHidden = false
            viewController.orangeDamage.isHidden = false
            viewController.yellowDamage.isHidden = true
            viewController.lightGreenDamage.isHidden = true
            viewController.greenDamage.isHidden = true
        case 0...3:
            viewController.redDamage.isHidden = false
            viewController.orangeDamage.isHidden = false
            viewController.yellowDamage.isHidden = false
            viewController.lightGreenDamage.isHidden = true
            viewController.greenDamage.isHidden = true
        case 0...4:
            viewController.redDamage.isHidden = false
            viewController.orangeDamage.isHidden = false
            viewController.yellowDamage.isHidden = false
            viewController.lightGreenDamage.isHidden = false
            viewController.greenDamage.isHidden = true
        default:
            viewController.redDamage.isHidden = false
            viewController.orangeDamage.isHidden = false
            viewController.yellowDamage.isHidden = false
            viewController.lightGreenDamage.isHidden = false
            viewController.greenDamage.isHidden = false
            break
        }
    }
    
    func accelerate(_ deltaTime : Double){
        if vel < 50{
            vel += 0.7*deltaTime
        }
        
        updateFuelMeter()
    }
    
    static func getTimer(currentTime time : Double) -> String{
        let minutes = Int(time/60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        
        var minString = String(minutes)
        if minString.count == 1{
            minString = "0" + minString
        }
        var secString = String(seconds)
        if secString.count == 1{
            secString = "0" + secString
        }
        
        return minString + ":" + secString
    }
    
    func endGame(gameOver permanent : Bool, timedWin win : Bool){
        isPaused = true
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if permanent{
            //it's only possible to win in timed mode
            if (win){
                soundWin?.play()
                viewController.overTimed(GameScene.getTimer(currentTime: timer))
                
                // UPDATE BEST TIME CORE DATA HERE
                let scoreRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BestTime")
                scoreRequest.returnsObjectsAsFaults = false
                
                do{
                    let times = try context.fetch(scoreRequest) as![NSManagedObject]
                    
                    if times.count > 0{
                        let bestTime = times[0]
                        if timer < bestTime.value(forKey: "time") as! Double{
                            bestTime.setValue(timer, forKey: "time")
                        }
                    } else{
                        let timeEntity = NSEntityDescription.entity(forEntityName: "BestTime", in: context)
                        let bestTime = NSManagedObject(entity: timeEntity!, insertInto: context)
                        bestTime.setValue(timer, forKey: "time")
                    }
                    
                    try context.save()
                }catch{
                    print("Failed saving best time \(error)")
                }
                
            }else{
                soundLose?.play()
                viewController.over()
            }
            
            //this is where we save if the game is over, as in we lost
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HighScore")
            request.returnsObjectsAsFaults = false
            
            do{
                let record = try context.fetch(request) as![NSManagedObject]
                
                if record.count > 0 {
                    let oldScore = record[0].value(forKey: "score") as! Int
                    
                    if distance > oldScore{
                        record[0].setValue(distance, forKey: "score")
                    }
                } else{
                    let entity = NSEntityDescription.entity(forEntityName: "HighScore", in: context)
                    let highscore = NSManagedObject(entity: entity!, insertInto: context)
                    highscore.setValue(distance, forKey: "score")
                }
                try context.save()

            }catch{
                print("load score failed \(error)")
            }
        }else{
            let entity = NSEntityDescription.entity(forEntityName: "PausedGame", in: context)
            let savedGame = NSManagedObject(entity: entity!, insertInto: context)
            savedGame.setValue(asteroid!.position.x, forKey: "asteroidX")
            savedGame.setValue(asteroid!.position.y, forKey: "asteroidY")
            savedGame.setValue(distance, forKey: "distance")
            savedGame.setValue(fuelCounter, forKey: "fuelCounter")
            savedGame.setValue(fuelAmt, forKey: "fuelAmt")
            savedGame.setValue(fuel!.position.x, forKey: "fuelX")
            savedGame.setValue(fuel!.position.y, forKey: "fuelY")
            savedGame.setValue(health, forKey: "health")
            savedGame.setValue(ship!.position.x, forKey: "playerX")
            savedGame.setValue(vel, forKey: "vel")
            
            if timeMode{
                savedGame.setValue(timeMode, forKey: "timeMode")
                savedGame.setValue(timer, forKey: "time")
            }

            do {
                try context.save()
            } catch{
                print("save game failed \(error)")
            }
        }
    }
    
    func setup(){
        
        //sound setup start
        
        if let asset = NSDataAsset(name: "menu_highlight_1"){
            do{
                soundCollect = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
                soundCollect?.volume = 5
            }catch{
                print("error loading sound")
            }
        }
        if let asset = NSDataAsset(name: "explosion_1_small"){
            do{
                soundExplode = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
                soundExplode?.volume = 5
            }catch{
                print("error loading sound")
            }
        }
        if let asset = NSDataAsset(name: "jingle_failure_3"){
            do{
                soundLose = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
            }catch{
                print("error loading sound")
            }
        }
        if let asset = NSDataAsset(name: "jingle_success_3"){
            do{
                soundWin = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
            }catch{
                print("error loading sound")
            }
        }
        
        //sound setup end
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PausedGame")
        request.returnsObjectsAsFaults = false
        if !isSavedGame{
            do {
                let savedGame = try context.fetch(request) as![NSManagedObject]
                if savedGame.count != 0{
                    context.delete(savedGame[0])
                    try context.save()
                }
            } catch{
                print("Error checking for existing games \(error)")
            }
            ship!.position = CGPoint(x: 0, y: -400)
            asteroid!.position = CGPoint(x: 0, y: 1000)
            distance = 0
            health = 5
            fuelAmt = 100
            fuelCounter = 8
        } else{
            do {
                let savedGame = try context.fetch(request) as![NSManagedObject]
                
                let game = savedGame[0]
                
                ship!.position.x = game.value(forKey: "playerX") as! CGFloat
                ship!.position.y = -400
                asteroid!.position.x = game.value(forKey: "asteroidX") as! CGFloat
                asteroid!.position.y = game.value(forKey: "asteroidY") as! CGFloat
                distance = game.value(forKey: "distance") as! Int
                health = game.value(forKey: "health") as! Int
                fuelAmt = game.value(forKey: "fuelAmt") as! Int
                fuelCounter = game.value(forKey: "fuelCounter") as! Int
                vel = game.value(forKey: "vel") as! Double
                
                if game.value(forKey: "isTimeMode") as! Bool{
                    timeMode = true
                    timer = game.value(forKey: "time") as! Double
                    viewController.setTimer = true
                    viewController.timer.isHidden = false
                }
                
                context.delete(game)
            }catch{
                print("Couldn't load saved game \(error)")
            }

            isPaused = false
            viewController.score.text = String(distance)
            
            updateFuelMeter()
            updateHealthMeter()
        }
    }
    
    func create(){
        self.addChild(finishLine!)
        self.addChild(ship!)
        self.addChild(asteroid!)
        self.addChild(fuel!)
        
        setup()
        created = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = true
        for t in touches { thePos = t.location(in: self) }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = true
        for t in touches { thePos = t.location(in: self) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
        thePos = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
        thePos = nil
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !created{
            create()
        }
        
        //this should run regardless of being paused. Makes speed consistent regardless of framerate
        let deltaTime = lastTime > 0 ? currentTime - lastTime : 0
        lastTime = currentTime
        if !isPaused{
            moveShip()
            moveAsteroid()
            moveFuel()
            collisionDetection()
            accelerate(deltaTime)
            timer+=deltaTime
            viewController.timer.text = GameScene.getTimer(currentTime: timer)
        }
    }
}
