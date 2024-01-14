//
//  getInitialSize.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import SwiftUI

struct GetInitialSizeModifier: ViewModifier {
  @Binding var size: CGSize?
  var disabled = false
  
  func body(content: Content) -> some View {
    content
      .background {
        if size == nil && !disabled {
          GeometryReader { geometry in
            Color.clear.onAppear {
              if size == nil {
                size = geometry.size
              }
            }
          }
        }
      }
  }
}

extension View {
  func getInitialSize(_ size: Binding<CGSize?>, disabled: Bool = false) -> some View {
    self.modifier(GetInitialSizeModifier(size: size, disabled: disabled))
  }
}
