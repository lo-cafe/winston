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
        .ifIOS17({ view in
          if #available(iOS 17.0, *) {
            view
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
          } else {
            view
              .frame(.screenW * 1.5, .bottomTrailing)
              .mask(
                EllipticalGradient(colors: [.black, .black.opacity(0.99), .black.opacity(0.98), .black.opacity(0.96), .black.opacity(0.92), .black.opacity(0.88), .black.opacity(0.85), .black.opacity(active ? 0.75 : 0.5), .black.opacity(active ? 0.65 : 0.3), .black.opacity(active ? 0.5 : 0.1), .black.opacity(active ? 0.4 : 0), .black.opacity(0)], center: .bottomTrailing, startRadiusFraction: active ? 0.25 : 0, endRadiusFraction: active ? 1 : 0)
                  .animation(.smooth, value: active)
              )
          }
        })
        .contentShape(Rectangle())
        .frame(width: contentWidth)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in dismiss() } )
        .clipped()
        .allowsHitTesting(active)
    }
}
