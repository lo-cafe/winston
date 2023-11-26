//
//  DustScene.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

import SpriteKit

class DustScene: SKScene, ObservableObject {
  
  let dustEmitterNode = SKEmitterNode(fileNamed: "Dust.sks")
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func willMove(from view: SKView) {
    self.backgroundColor = .clear
  }
  
  override func didMove(to view: SKView) {
    guard let snowEmitterNode = dustEmitterNode else { return }
    
    addChild(snowEmitterNode)
    self.backgroundColor = .clear
    view.isAsynchronous = true
    snowEmitterNode.speed = 0.5
  }
    
  override func didChangeSize(_ oldSize: CGSize) {
    guard let snowEmitterNode = dustEmitterNode else { return }
    snowEmitterNode.particlePosition = CGPoint(x: size.width/2, y: 0)
    snowEmitterNode.particlePositionRange = CGVector(dx: size.width, dy: 0)
  }
}
