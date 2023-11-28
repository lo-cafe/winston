//
//  DustScene.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

import SpriteKit

class DustScene: SKScene {
  
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = .clear
    self.view?.isAsynchronous = true
    self.view?.scene?.shouldRasterize = true
    self.view?.layer.shouldRasterize = true
    if let dustEmitterNode = SKEmitterNode(fileNamed: "Dust.sks") {
      dustEmitterNode.name = "dust"
      dustEmitterNode.advanceSimulationTime(5)
      dustEmitterNode.speed = 0.5
      dustEmitterNode.particlePosition = CGPoint(x: size.width/2, y: 0)
      dustEmitterNode.particlePositionRange = CGVector(dx: size.width, dy: 0)
      addChild(dustEmitterNode)
    }
  }
  
  deinit {
    self.removeAllChildren()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    guard let dustEmitterNode = children.first(where: { $0.name == "dust" }) as? SKEmitterNode else { return }
    dustEmitterNode.particleBirthRate = 4
    dustEmitterNode.advanceSimulationTime(5)
//    view.isAsynchronous = true
  }
    
//  override func didChangeSize(_ oldSize: CGSize) {
//    guard let dustEmitterNode = children.first(where: { $0.name == "dust" }) as? SKEmitterNode else { return }
//    dustEmitterNode.particlePosition = CGPoint(x: size.width/2, y: 0)
//    dustEmitterNode.particlePositionRange = CGVector(dx: size.width, dy: 0)
//  }
}
