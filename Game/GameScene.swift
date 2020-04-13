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
    
    private var ship : SKSpriteNode?
    private var asteroid : SKSpriteNode?
    private var fuel : SKSpriteNode?
    private var fuelActive = false
    private var created = false
    private var vel = 1.0
    private var moving = false
    private var thePos: CGPoint?
    private var distance: Int = 0
    private var distanceLabel = SKLabelNode()
    private var health = 0
    private var healthLabel = SKLabelNode()
    private var fuelAmt = 0.0
    private var fuelCounter = 0.0
    private var lastTime = -1.0
    
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
        }
    }
    
    func moveFuel(){
        if fuelActive{
            fuel!.position.y -= CGFloat(vel)
            if fuel!.position.y < -800{
                fuelActive = false
            }
        }
    }
    
    func collisionDetection(){
        //for asteroids
        if abs(ship!.position.x - asteroid!.position.x) < (ship!.size.width + asteroid!.size.width) * 0.25 {
            if abs(ship!.position.y - asteroid!.position.y) < (ship!.size.height + asteroid!.size.height) * 0.4 {
                vel = 2
                health -= 1
                healthLabel.text = "Health: \(health)"
                //PLEASE SOMEONE MAKE THIS LOOK BETTER BUT IT WORKS
                if health <= 0{
                    viewController.greenDamage.isHidden = true
                    viewController.lightGreenDamage.isHidden = true
                    viewController.yellowDamage.isHidden = true
                    viewController.orangeDamage.isHidden = true
                    viewController.redDamage.isHidden = true
                }else if health <= 20{
                    viewController.greenDamage.isHidden = true
                    viewController.lightGreenDamage.isHidden = true
                    viewController.yellowDamage.isHidden = true
                    viewController.orangeDamage.isHidden = true
                    viewController.redDamage.isHidden = false
                }else if health <= 40{
                    viewController.greenDamage.isHidden = true
                    viewController.lightGreenDamage.isHidden = true
                    viewController.yellowDamage.isHidden = true
                    viewController.orangeDamage.isHidden = false
                    viewController.redDamage.isHidden = false
                }else if health <= 60{
                    viewController.greenDamage.isHidden = true
                    viewController.lightGreenDamage.isHidden = true
                    viewController.yellowDamage.isHidden = false
                    viewController.orangeDamage.isHidden = false
                    viewController.redDamage.isHidden = false
                }else if health <= 80{
                    viewController.greenDamage.isHidden = true
                    viewController.lightGreenDamage.isHidden = false
                    viewController.yellowDamage.isHidden = false
                    viewController.orangeDamage.isHidden = false
                    viewController.redDamage.isHidden = false
                }else{
                    viewController.greenDamage.isHidden = false
                    viewController.lightGreenDamage.isHidden = false
                    viewController.yellowDamage.isHidden = false
                    viewController.orangeDamage.isHidden = false
                    viewController.redDamage.isHidden = false
                }
                
                //END OF UGLY
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
                fuelActive = false
            }
        }
    }
    
    func updateDistance(){
        distance += Int(vel / 10)
        distanceLabel.text = "Score: \(distance)"
    }
    
    func accelerate(_ deltaTime : Double){
        if vel < 50{
            vel += 0.5*deltaTime
        }
        fuelAmt -= deltaTime*1
        //BAD CODE BELOW
        if fuelAmt <= 0{
            viewController.greenFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.yellowFuel.isHidden = true
            viewController.orangeFuel.isHidden = true
            viewController.redFuel.isHidden = true
        }else if fuelAmt <= 20{
            viewController.greenFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.yellowFuel.isHidden = true
            viewController.orangeFuel.isHidden = true
            viewController.redFuel.isHidden = false
        }else if fuelAmt <= 40{
            viewController.greenFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.yellowFuel.isHidden = true
            viewController.orangeFuel.isHidden = false
            viewController.redFuel.isHidden = false
        }else if fuelAmt <= 60{
            viewController.greenFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = true
            viewController.yellowFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.redFuel.isHidden = false
        }else if fuelAmt <= 80{
            viewController.greenFuel.isHidden = true
            viewController.lightGreenFuel.isHidden = false
            viewController.yellowFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.redFuel.isHidden = false
        }else{
            viewController.greenFuel.isHidden = false
            viewController.lightGreenFuel.isHidden = false
            viewController.yellowFuel.isHidden = false
            viewController.orangeFuel.isHidden = false
            viewController.redFuel.isHidden = false
        }
        //END OF BAD CODE
        fuelCounter -= deltaTime*1
        if fuelCounter <= 0 && !fuelActive{
            fuelCounter = 20.0
            fuel!.position.x = CGFloat(Int.random(in: 275...275))
            fuel!.position.y = 800
            fuelActive = true
        }
        if fuelAmt <= 0{
            endGame(gameOver: true)
        }
    }
    
    func endGame(gameOver permanent : Bool){
        isPaused = true
        if permanent{
            //this is where we save if the game is over, as in we lost
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
            print("Temp Test \(fuelAmt)")
            
            //this is where we save for resuming the game
        }
    }
    
    func setup(){
        ship!.position = CGPoint(x: 0, y: -400)
        asteroid!.position = CGPoint(x: 0, y: 1000)
        distance = 0
        distanceLabel.text = "Score: \(distance)"
        health = 100
        fuelAmt = 100
        healthLabel.text = "Health: \(health)"
        fuelCounter = 10.0
        fuelActive = false
        isPaused = false
    }
    
    func create(){
        self.addChild(ship!)
        self.addChild(asteroid!)
        self.addChild(fuel!)
        distanceLabel.position.x = 200
        distanceLabel.position.y = -550
        distanceLabel.color = SKColor.white
        self.addChild(distanceLabel)
        healthLabel.position.x = -200
        healthLabel.position.y = -550
        healthLabel.color = SKColor.white
        self.addChild(healthLabel)
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
            updateDistance()
            collisionDetection()
            accelerate(deltaTime)
        }
    }
}
