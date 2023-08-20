//
//  MorphingGradientCircleScene.swift
//  damage
//
//  Created by Igor Marcossi on 26/04/23.
//

import Foundation
import SpriteKit
import SwiftUI

let offsetVariation = 0.05 / 2
let scaleVariation: CGFloat = 0.3 / 2
let duration = 1.0

class MorphingGradientCircleScene: SKScene {
    var mainAction: SKAction?
    var activeAction: SKAction?
    var texture = SKTexture(imageNamed: "ball")
    var active: Bool = false {
        didSet {
            updateActive()
        }
    }
    //    var colors: [UIColor] = [.cyan]
    //    var colors: [UIColor] = [.cyan, .systemMint, .systemYellow, .systemTeal, .systemPink, .red, .blue]
    var colors: [UIColor] = [UIColor(Color("blueish")), UIColor(Color("greenish")), UIColor(Color("pinkish")), UIColor(Color("yellowish")), UIColor(Color("tealish"))]
    var changer: CGFloat = 1.0
    
    func cubicBezier(_ t: CGFloat, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> CGFloat {
        let oneMinusT = 1 - t
        let oneMinusT2 = oneMinusT * oneMinusT
        let t2 = t * t
        return 3 * oneMinusT2 * t * y1 + 3 * oneMinusT * t2 * y2 + t2 * t
    }
    
    func generateOffset() -> CGFloat {
        return CGFloat.random(in: -offsetVariation...offsetVariation)
    }
    
    func updateActive() {
        removeAllActions()
        children.forEach({ x in x.removeAllActions()})
        if active {
            activeAction = SKAction.run {
                for (index, _) in self.colors.enumerated() {
                    let targetPosition = CGPoint(x: 0.5 + CGFloat.random(in: 0.05...0.2) * randomNegative(), y: 0.5 + CGFloat.random(in: 0.05...0.2) * randomNegative())
                    
                    let moveAction = SKAction.move(to: targetPosition, duration: 0.2)
                    moveAction.timingFunction = { [self] time in
                        return Float(self.cubicBezier(CGFloat(time), 0.25, 0.1, 0.25, 1.0)) // Adjust the control points to change the timing curve
                    }
                    self.activeAction = SKAction.group([
                        //                .colorize(with: color, colorBlendFactor: 1.0, duration: duration),
                        moveAction,
                        .scale(to: CGFloat.random(in: 0.8...1.45), duration: 0.2),
                        .fadeAlpha(to: CGFloat.random(in: 0.5...0.9), duration: 0.2),
                    ])
                    self.children[index].run(self.activeAction!)
                }
            }
            run(activeAction!)
        } else {
            updateAnimation()
        }
    }
    
    func updateAnimation(_ altDuration: CGFloat? = duration) {
        mainAction = SKAction.sequence([
            .run(recolorAll()),
            .wait(forDuration: altDuration!)
        ])
        run(SKAction.repeatForever(mainAction!))
    }
    
    func recolorAll(_ altDuration: CGFloat? = nil) -> (() -> Void) {
        let actualDuration = (altDuration ?? duration)!
        func doIt() {
            if active { return }
            colors.shuffle()
            for (index, color) in colors.enumerated() {
                let targetPosition = CGPoint(x: 0.5 + generateOffset(), y: 0.5 + generateOffset())
                
                let moveAction = SKAction.move(to: targetPosition, duration: actualDuration)
                moveAction.timingFunction = { [self] time in
                    return Float(self.cubicBezier(CGFloat(time), 0.25, 0.1, 0.25, 1.0)) // Adjust the control points to change the timing curve
                }
                let action = SKAction.group([
                    .colorize(with: color, colorBlendFactor: 1.0, duration: actualDuration),
                    //                .move(to: CGPoint(x: 150 + generateOffset(), y: 150 + generateOffset()), duration: actualDuration),
                    .scale(to: CGFloat.random(in: 1 - scaleVariation...1), duration: actualDuration),
                    moveAction,
                    .fadeAlpha(to: CGFloat.random(in: 0.7...1.0), duration: actualDuration),
                ])
                children[index].run(action)
            }
        }
        return doIt
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.isAsynchronous = true
        
        for (index, color) in colors.enumerated() {
            let circleNode = SKSpriteNode(texture: texture)
            circleNode.zPosition = CGFloat(index)
            circleNode.position = CGPoint(x: 0.5, y: 0.5)
            circleNode.color = color
            circleNode.size = CGSize(width: 0.125, height: 0.125)
            circleNode.colorBlendFactor = 1.0
            
            addChild(circleNode)
        }
        updateActive()
    }
}

func randomNegative() -> CGFloat {
    return Int.random(in: 1...2) == 1 ? -1.0 : 1.0
}
