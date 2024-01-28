//
//  BGBlur.swift
//  winston
//
//  Created by Igor Marcossi on 28/12/23.
//

import SwiftUI

struct FloatingBGBlur: View, Equatable {
  static func == (lhs: FloatingBGBlur, rhs: FloatingBGBlur) -> Bool {
    lhs.active == rhs.active
  }
  
  @Environment(\.contentWidth) var contentWidth
  
  let active: Bool
  let dismiss: ()->()
  var body: some View {
    Rectangle()
      .fill(.bar)
      .frame(width: .screenW * 5, height: (!IPAD ? .screenW * 1.65 : .screenH * 0.75), alignment: .bottomTrailing)
      .mask(
        EllipticalGradient(
          gradient: .smooth(from: .black, to: .black.opacity(0), curve: .easeIn),
          center: .bottomTrailing,
          startRadiusFraction: active ? 0.5 : 0,
          endRadiusFraction: active ? 1 : 0
        )
        .animation(.smooth, value: active)
      )
      .contentShape(Rectangle())
      .frame(width: contentWidth)
      .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in dismiss() } )
      .clipped()
      .allowsHitTesting(active)
  }
}
