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
    
    private var running = false
    private var ship : SKSpriteNode?
    private var asteroid : SKSpriteNode?
    private var created = false
    private var vel = 1.0
    private var moving = false
    private var thePos: CGPoint?
    private var distance: Int = 0
    private var distanceLabel = SKLabelNode()
    private var health = 0
    private var healthLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        self.ship = SKSpriteNode.init(imageNamed: "ship")
        ship?.size = CGSize(width: 120, height: 200)
        self.asteroid = SKSpriteNode.init(imageNamed: "meteor")
        asteroid?.size = CGSize(width: 250, height: 160)
        
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
    
    func collisionDetection(){
        if abs(ship!.position.x - asteroid!.position.x) < (ship!.size.width + asteroid!.size.width) * 0.25 {
            if abs(ship!.position.y - asteroid!.position.y) < (ship!.size.height + asteroid!.size.height) * 0.4 {
                vel = 2
                health -= 1
                healthLabel.text = "Health: \(health)"
                
                if health == 0{
                    endGame()
                }
            }
        }
    }
    
    func updateDistance(){
        distance += Int(vel / 10)
        distanceLabel.text = "Score: \(distance)"
    }
    
    func accelerate(){
        if vel < 50{
            vel += 0.1
        }
    }
    
    func endGame(){
        running = false
        
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
    }
    
    func setup(){
        ship!.position = CGPoint(x: 0, y: -400)
        asteroid!.position = CGPoint(x: 0, y: 1000)
        distance = 0
        distanceLabel.text = "Score: \(distance)"
        health = 100
        healthLabel.text = "Health: \(health)"
        running = true
    }
    
    func create(){
        self.addChild(ship!)
        self.addChild(asteroid!)
        distanceLabel.position.x = 200
        distanceLabel.position.y = 550
        distanceLabel.color = SKColor.white
        self.addChild(distanceLabel)
        healthLabel.position.x = -200
        healthLabel.position.y = 550
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
        
        if running{
            moveShip()
            moveAsteroid()
            updateDistance()
            collisionDetection()
            accelerate()
        }
    }
}
