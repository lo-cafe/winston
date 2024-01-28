//
//  if.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI

extension View {
  @ViewBuilder func `if`<C: View>(_ condition: Bool, transform: (Self) -> C) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
  @ViewBuilder func `ifLet`<C: View, E: Any>(_ el: E?, transform: (Self, E) -> C) -> some View {
    if let el {
      transform(self, el)
    } else {
      self
    }
  }
}
