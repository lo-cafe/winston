//
//  ComingFrom.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import SwiftUI

extension AnyTransition {
  static func comeFrom(_ side: Edge, index: Int, total: Int, delay: Double = 0.125, disableEndDelay: Bool = false, disableScale: Bool = false) -> AnyTransition {
    AnyTransition.modifier(
      active: ComeFromBotTrans(side: side, isActive: false, delay: disableEndDelay ? 0 : Double(total - 1 - index) * delay, disableScale: disableScale),
      identity: ComeFromBotTrans(side: side, isActive: true, delay: delay * Double(index), disableScale: disableScale)
    )
  }
}

struct ComeFromBotTrans: ViewModifier {
  let side: Edge
  let isActive: Bool
  let delay: Double
  let disableScale: Bool
  
  private func offsetFor(_ x: Edge) -> Double {
    return switch x {
    case .top, .leading: -24
    case .bottom, .trailing: 24
    }
  }
  
  private func edgeToUnit(_ x: Edge) -> UnitPoint {
    return switch x {
    case .top: .top
    case .bottom: .bottom
    case .leading: .leading
    case .trailing: .trailing
    }
  }
  
  func body(content: Content) -> some View {
    let hor = side == .leading || side == .trailing
    content
      .scaleEffect(disableScale || isActive ? 1 : 0.01, anchor: edgeToUnit(side))
      .opacity(isActive ? 1 : 0)
      .offset(x: !disableScale || isActive || !hor ? 0 : offsetFor(side), y: !disableScale || isActive || hor ? 0 : offsetFor(side))
      .zIndex(isActive ? 0 : -1)
      .animation(.bouncy.delay(delay), value: isActive)
  }
}
