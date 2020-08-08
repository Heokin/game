//
//  GameScene.swift
//  game
//
//  Created by Stas Dashkevich on 7/29/20.
//  Copyright © 2020 Stas Dashkevich. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    // паралакс
    var gameBackground: SKSpriteNode!
    // создаем свойства
    var score = 0
    var scoreLabel: SKLabelNode!
    //создаем экз
    var spaceGame: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        scene?.size = UIScreen.main.bounds.size
       gameBackground = SKSpriteNode(imageNamed: "background")
        addChild(gameBackground)
        
        // инициализация
         spaceGame = SKSpriteNode(imageNamed: "mainImage")
        spaceGame.xScale = 1.5
        spaceGame.yScale = 1.5
        // physics
        spaceGame.physicsBody = SKPhysicsBody(texture: spaceGame.texture!, size: spaceGame.size)
        spaceGame.physicsBody?.isDynamic = false
        
        spaceGame.physicsBody?.categoryBitMask = spaceShipCategory
        spaceGame.physicsBody?.collisionBitMask = asteroidCategory | asteroidCategory
        spaceGame.physicsBody?.contactTestBitMask = asteroidCategory
//        spaceGame.position = CGPoint(x: 80, y: 100)
        // добавляем на сцену
        addChild(spaceGame)
        // generation asteroid
        let asteroidCreate = SKAction.run {
            let asteroid = self.createdangerous()
            asteroid.zPosition = 1
            self.addChild(asteroid)
        }
        let asteroidPS: Double = 10
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0, withRange: asteroidPS)
        let asteroidActions = SKAction.sequence([asteroidCreate,asteroidCreationDelay])
        let asteriodRunAction = SKAction.repeatForever(asteroidActions)
        
        run(asteriodRunAction)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 300)
        addChild(scoreLabel)
        
        gameBackground.zPosition = 0
        spaceGame.zPosition = 2
        
        scoreLabel.zPosition = 3
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // определяем точка касания
            let touchLocation = touch.location(in: self)
            print(touchLocation)
            
            let distance = distanceCulc(a: spaceGame.position, b:touchLocation)
            let speed: CGFloat = 500
            let time = timeToDistance(distance: distance, speed: speed)
            let moveAction = SKAction.move(to: touchLocation, duration: time)
            print("distance \(distance)")
            print("time \(time)")
                
            // создаем действие
            
            spaceGame.run(moveAction)
            
            let BGMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 50, y: -touchLocation.y / 50), duration: time)
            gameBackground.run(BGMoveAction)
        }
    }

    func distanceCulc(a:CGPoint, b:CGPoint) -> CGFloat{
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    func timeToDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval{
        let time = distance / speed
        return TimeInterval(time)
    }
func createdangerous() -> SKSpriteNode {
    let asteroid = SKSpriteNode(imageNamed: "3")
    asteroid.name = "asteroid"
    let randonScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound:4)) / 10
    asteroid.xScale = randonScale
    asteroid.yScale = randonScale
//    asteroid.xScale = 0.5
//    asteroid.yScale = 0.5
//    asteroid.position.x = CGFloat(arc4random()) / frame.size.width
    asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound:6))
    asteroid.position.y = frame.size.height + asteroid.size.height
    
    asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
    
    asteroid.physicsBody?.categoryBitMask = asteroidCategory
    asteroid.physicsBody?.collisionBitMask = spaceShipCategory
    asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
    return asteroid
}
    override func update(_ currentTime: TimeInterval) {
//        let asteroid = createdangerous()
//        addChild(asteroid)
    }

    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "asteroid") { (asteroid, stop) in
            let hight = UIScreen.main.bounds.height
            if asteroid.position.y < -hight {
                asteroid.removeFromParent()
                
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }

    
     func didBegin(_ contact: SKPhysicsContact){
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }

    func didEnd(_ contact: SKPhysicsContact){
       
    }
    
}
