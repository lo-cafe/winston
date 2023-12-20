//
//  Scacity.swift
//  winston
//
//  Created by Igor Marcossi on 16/12/23.
//

import SwiftUI

extension AnyTransition {
  public static var scacity: AnyTransition = .scale.combined(with: .opacity.combined(with: .offset(y: 24)))
  public func delayInOrder(_ index: Int, total: Int, delay: Double = 1.125) -> AnyTransition {
    .asymmetric(
      insertion: self.animation(.bouncy.delay(delay * Double(index))),
      removal: self.animation(.bouncy.delay(Double(total - 1 - index) * delay))
    )
  }
}

extension AnyTransition {
  static func comeFrom(_ side: Edge, index: Int, total: Int, delay: Double = 0.125, disableEndDelay: Bool = false) -> AnyTransition {
    AnyTransition.modifier(
      active: ComeFromBotTrans(side: side, isActive: false, delay: disableEndDelay ? 0 : Double(total - 1 - index) * delay),
      identity: ComeFromBotTrans(side: side, isActive: true, delay: delay * Double(index))
    )
  }
}

struct ComeFromBotTrans: ViewModifier {
    let side: Edge
    let isActive: Bool
    let delay: Double
  
  private func offsetFor(_ x: Edge) -> Double {
    return switch x {
      case .top: -24
      case .bottom: 24
      case .leading: -24
      case .trailing: 24
    }
  }
    
  func body(content: Content) -> some View {
    let hor = side == .leading || side == .trailing
        content
            .scaleEffect(isActive ? 1 : 0.01)
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive || !hor ? 0 : offsetFor(side), y: isActive || hor ? 0 : offsetFor(side))
            .zIndex(isActive ? 0 : -1)
            .animation(.bouncy.delay(delay), value: isActive)
    }
}
