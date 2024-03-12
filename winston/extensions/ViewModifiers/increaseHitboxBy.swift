//
//  increaseHitboxBy.swift
//  winston
//
//  Created by Igor Marcossi on 28/12/23.
//

import SwiftUI

extension View {
  func increaseHitboxBy<S: Shape>(_ amount: Double, shape: S = Rectangle(), disable: Bool = false) -> some View {
    self.background(GeometryReader { Color.hitbox.frame($0.size * (disable ? 1 : amount)).contentShape(shape) })
  }
  func increaseHitboxOf<S: Shape>(_ size: CGSize, by: Double, shape: S = Rectangle(), disable: Bool = false) -> some View {
    self.background(Color.hitbox.frame(size * (disable ? 1 : by)).contentShape(shape))
  }
  func increaseHitboxOf<S: Shape>(_ size: Double, by: Double, shape: S = Rectangle(), disable: Bool = false) -> some View {
    self.background(Color.hitbox.frame(size * (disable ? 1 : by)).contentShape(shape))
  }
}
