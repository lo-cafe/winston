//
//  nsfw.swift
//  winston
//
//  Created by Igor Marcossi on 02/08/23.
//

import SwiftUI

struct NSFWMod: ViewModifier {
  var isIt: Bool
  var size: CGSize? = nil
  var smallIcon: Bool = false
  @State private var unblur = false
  func body(content: Content) -> some View {
    let blur = !unblur && isIt
    let squareSize: Double = size == nil ? 0 : min(size!.width, size!.height)
    if isIt {
      content
        .frame(minHeight: isIt ? 75 : 0)
        .opacity(blur ? 0.75 : 1)
        .blur(radius: blur ? 30 : 0)
        .allowsHitTesting(!blur)
        .mask(RR(blur ? squareSize / 2 : 0, .black).frame(width: blur ? squareSize : size?.width, height: blur ? squareSize : size?.height).blur(radius: blur ? smallIcon ? 12 : 24 : 0))
        .scaleEffect(blur ? 0.95 : 1)
        .overlay(
          !blur
          ? nil
          : NSFWOverlay(smallIcon: smallIcon).equatable().transition(.scaleAndBlur).highPriorityGesture(blur ? TapGesture().onEnded { withAnimation(.spring) { unblur = true } } : nil )
        )
    } else {
      content
    }
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
  func nsfw(_ isIt: Bool,smallIcon: Bool = false, size: CGSize? = nil) -> some View {
    self
      .modifier(NSFWMod(isIt: isIt, size: size, smallIcon: smallIcon))
  }
}
