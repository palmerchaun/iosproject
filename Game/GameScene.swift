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
    
    private var ship : SKSpriteNode?
    private var asteroid : SKSpriteNode?
    private var fuel : SKSpriteNode?
    private var created = false
    private var vel = 2.0
    private var moving = false
    private var thePos: CGPoint?
    private var distance: Int = 0
    private var health = 0
    private var fuelAmt = 0
    private var fuelCounter = 0
    private var lastTime = -1.0
    private var crashing = false
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        self.ship = SKSpriteNode.init(imageNamed: "ship")
        ship?.size = CGSize(width: 120, height: 200)
        self.asteroid = SKSpriteNode.init(imageNamed: "meteor")
        asteroid?.size = CGSize(width: 250, height: 160)
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
        if asteroid!.position.y < -800{
            asteroid!.position.y = 800
            asteroid!.position.x = CGFloat(Int.random(in: -325...325))
            if crashing{
                crashing = false
                vel = 2
                asteroid?.scale(to: CGSize(width: 250, height: 160))
            }
            else{
                updateDistance()
            }
            
            fuelAmt -= 5
            fuelCounter -= 1
            if fuelCounter <= 0 {
                fuelCounter = 8
                fuel!.position.x = CGFloat(Int.random(in: -275...275))
                fuel!.position.y = 1600
            }
            if fuelAmt <= 0{
                endGame(gameOver: true)
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
                if !crashing{
                    vel = 10
                    health -= 1
                }
                crashing = true
                asteroid!.scale(to: CGSize.zero)
                
                switch(health){
                case 0:
                    viewController.redDamage.isHidden = true
                case 1:
                    viewController.orangeDamage.isHidden = true
                case 2:
                    viewController.yellowDamage.isHidden = true
                case 3:
                    viewController.lightGreenDamage.isHidden = true
                case 4:
                    viewController.greenDamage.isHidden = true
                default:
                    break
                }
                
                if health == 0{
                    endGame(gameOver: true)
                }
            }
        }
        //for fuel
        if abs(ship!.position.x - fuel!.position.x) < (ship!.size.width + fuel!.size.width) * 0.25 {
            if abs(ship!.position.y - fuel!.position.y) < (ship!.size.height + fuel!.size.height) * 0.4 {
                fuelAmt = 100
                fuel!.position.y = -800
                viewController.redFuel.isHidden = false
                viewController.orangeFuel.isHidden = false
                viewController.yellowFuel.isHidden = false
                viewController.lightGreenFuel.isHidden = false
                viewController.greenFuel.isHidden = false
            }
        }
    }
    
    func updateDistance(){
        distance += 1
        viewController.score.text = String(distance)
    }
    
    func accelerate(_ deltaTime : Double){
        if vel < 50{
            vel += 0.5*deltaTime
        }
        
        switch(fuelAmt){
        case ...0:
            viewController.redFuel.isHidden = true
        case 1...20:
            viewController.orangeFuel.isHidden = true
        case 21...40:
            viewController.yellowFuel.isHidden = true
        case 41...60:
            viewController.lightGreenFuel.isHidden = true
        case 61...80:
            viewController.greenFuel.isHidden = true
        default:
            break
        }
    }
    
    func endGame(gameOver permanent : Bool){
        isPaused = true
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if permanent{
            viewController.over()
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

            do {
                try context.save()
            } catch{
                print("save game failed \(error)")
            }
        }
    }
    
    func setup(){
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
                
                context.delete(game)
            }catch{
                print("Couldn't load saved game \(error)")
            }

            isPaused = false
            viewController.score.text = String(distance)
            switch(health){
            case 0:
                viewController.redDamage.isHidden = true
                viewController.orangeDamage.isHidden = true
                viewController.yellowDamage.isHidden = true
                viewController.lightGreenDamage.isHidden = true
                viewController.greenDamage.isHidden = true
            case 0..<1:
                viewController.orangeDamage.isHidden = true
                viewController.yellowDamage.isHidden = true
                viewController.lightGreenDamage.isHidden = true
                viewController.greenDamage.isHidden = true
            case 0..<2:
                viewController.yellowDamage.isHidden = true
                viewController.lightGreenDamage.isHidden = true
                viewController.greenDamage.isHidden = true
            case 0..<3:
                viewController.lightGreenDamage.isHidden = true
                viewController.greenDamage.isHidden = true
            case 0..<4:
                viewController.greenDamage.isHidden = true
            default:
                break
            }
            
            switch(fuelAmt){
            case 0:
                viewController.redFuel.isHidden = true
                viewController.orangeFuel.isHidden = true
                viewController.yellowFuel.isHidden = true
                viewController.lightGreenFuel.isHidden = true
                viewController.greenFuel.isHidden = true
            case 0..<1:
                viewController.orangeFuel.isHidden = true
                viewController.yellowFuel.isHidden = true
                viewController.lightGreenFuel.isHidden = true
                viewController.greenFuel.isHidden = true
            case 0..<2:
                viewController.yellowFuel.isHidden = true
                viewController.lightGreenFuel.isHidden = true
                viewController.greenFuel.isHidden = true
            case 0..<3:
                viewController.lightGreenFuel.isHidden = true
                viewController.greenFuel.isHidden = true
            case 0..<4:
                viewController.greenFuel.isHidden = true
            default:
                break
            }

        }
    }
    
    func create(){
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
        }
    }
}
