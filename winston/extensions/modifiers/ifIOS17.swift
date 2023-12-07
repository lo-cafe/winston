//
//  ifIOS17.swift
//  winston
//
//  Created by Igor Marcossi on 20/09/23.
//

import SwiftUI

extension View {
  @ViewBuilder
  func ifIOS17<Content: View>(@ViewBuilder _ withModifiers: (Self) -> Content) -> some View {
    if #available(iOS 17, *) {
      withModifiers(self)
    } else {
      self
    }
  }
}
