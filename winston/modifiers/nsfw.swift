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
      .allowsHitTesting(!blur)
      .overlay(
        !blur
        ? nil
        : NSFWOverlay(smallIcon: smallIcon).equatable().highPriorityGesture(blur && !smallIcon ? TapGesture().onEnded { withAnimation { unblur = true } } : nil )
      )
      .allowsHitTesting(smallIcon ? false : !blur)
  }
}

struct NSFWOverlay: View, Equatable {
  static func == (lhs: NSFWOverlay, rhs: NSFWOverlay) -> Bool { true }

  var smallIcon: Bool = false
  var body: some View {
    VStack {
      Text("NSFW")
        .fontSize(15, .medium)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.red, in: Capsule(style: .continuous))
        .foregroundColor(.white)
      if !smallIcon { Text("Tap to unblur") }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .contentShape(Rectangle())
  }
}

extension View {
  func nsfw(_ isIt: Bool,smallIcon: Bool = false) -> some View {
    self
      .modifier(NSFWMod(isIt: isIt, smallIcon: smallIcon))
  }
}
