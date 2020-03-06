//
//  GameScene.swift
//  Game
//
//  Created by Seth Palmer on 3/5/20.
//  Copyright © 2020 Seth Palmer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    private var asteroid : SKShapeNode?
    private var created = false
    private var vel = 1.0
    private var moving = false
    private var thePos: CGPoint?
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        self.asteroid = SKShapeNode.init(circleOfRadius: w)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        }
        
        if let asteroid = self.asteroid {
            asteroid.fillColor = UIColor.red
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if pos.x < spinnyNode!.position.x{
            if abs(pos.x - spinnyNode!.position.x) > 20{
                spinnyNode!.position.x -= 20
            } else{
                spinnyNode!.position.x = pos.x
            }
        } else if pos.x > spinnyNode!.position.x{
            if abs(pos.x - spinnyNode!.position.x) > 20{
                spinnyNode!.position.x += 20
            } else{
                spinnyNode!.position.x = pos.x
            }
        }
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
            self.addChild(spinnyNode!)
            self.addChild(asteroid!)
            spinnyNode!.position = CGPoint(x: 0, y: -400)
            asteroid!.position = CGPoint(x: 0, y: 1000)
            created = true
        }
        
        if moving {
            touchMoved(toPoint: thePos!)
        }
        asteroid!.position.y -= CGFloat(vel)
        if asteroid!.position.y < -1000{
            asteroid!.position.y = 1000
            asteroid!.position.x = CGFloat(Int.random(in: -200...200))
        }
        
        if sqrt(pow(Double(asteroid!.position.x - spinnyNode!.position.x), 2.0) + pow(Double(asteroid!.position.y - spinnyNode!.position.y), 2)) < 155{
            vel = 2
        }
        vel += 0.1
    }
}
