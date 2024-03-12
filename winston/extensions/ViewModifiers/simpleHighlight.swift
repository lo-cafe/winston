//
//  simpleHighlight.swift
//  winston
//
//  Created by Igor Marcossi on 07/01/24.
//

import SwiftUI

extension View {
  func simpleHighlight(_ pressed: Bool, opacity: Double = 0.1) -> some View {
    self
      .overlay { Color.primary.opacity(pressed ? opacity : 0).allowsHitTesting(false) }
  }
  func simpleHighlight<S: Shape>(_ pressed: Bool, clip: S, opacity: Double = 0.1) -> some View {
    self
      .overlay { Color.primary.opacity(pressed ? opacity : 0).clipShape(clip).allowsHitTesting(false) }
  }
}
