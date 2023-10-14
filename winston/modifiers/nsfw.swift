//
//  nsfw.swift
//  winston
//
//  Created by Igor Marcossi on 02/08/23.
//

import SwiftUI

struct NSFWMod: ViewModifier {
  var isIt: Bool
  var smallIcon: Bool = false
  @State private var unblur = false
  func body(content: Content) -> some View {
    let blur = !unblur && isIt
    content
      .frame(minHeight: isIt ? 75 : 0)
      .opacity(blur ? 0.75 : 1)
      .blur(radius: blur ? 30 : 0)
      .mask(content)
      .overlay(
        !blur
        ? nil
        : VStack {
          Text("NSFW")
            .fontSize(15, .medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.red, in: Capsule(style: .continuous))
            .foregroundColor(.white)
          smallIcon ? nil :  Text("Tap to unblur")
        }
      )
      .allowsHitTesting(smallIcon ? false : !blur)
      .contentShape(Rectangle())
      .highPriorityGesture(smallIcon ? nil : blur ? TapGesture().onEnded { withAnimation { unblur = true } } : nil )
  }
}

extension View {
  func nsfw(_ isIt: Bool,smallIcon: Bool = false) -> some View {
    self
      .modifier(NSFWMod(isIt: isIt, smallIcon: smallIcon))
  }
}
