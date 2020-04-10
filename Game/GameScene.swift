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

class GameScene: SKScene, AVAudioPlayerDelegate {
    
    private var ship : SKSpriteNode?
    private var asteroid : SKSpriteNode?
    private var created = false
    private var vel = 1.0
    private var moving = false
    private var thePos: CGPoint?
    
    
    
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
        if asteroid!.position.y < -900{
            asteroid!.position.y = 900
            asteroid!.position.x = CGFloat(Int.random(in: -350...350))
        }
    }
    
    func collisionDetection(){
        if abs(ship!.position.x - asteroid!.position.x) < (ship!.size.width + asteroid!.size.width) * 0.25 {
            if abs(ship!.position.y - asteroid!.position.y) < (ship!.size.height + asteroid!.size.height) * 0.4 {
                vel = 2
            }
        }
    }
    
    func setup(){
        ship!.position = CGPoint(x: 0, y: -400)
        asteroid!.position = CGPoint(x: 0, y: 1000)
    }
    
    func create(){
        self.addChild(ship!)
        self.addChild(asteroid!)
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
        
        moveShip()
        moveAsteroid()
        collisionDetection()

        vel += 0.1
    }
}
