//
//  tipJarModalProvider.swift
//  winston
//
//  Created by Igor Marcossi on 19/03/24.
//

import SwiftUI

struct TipJarModalModifier: ViewModifier {
  @State var render = false
  
  func openTipJar() { if !render { withAnimation(.spring) { render = true } } }
  func closeTipJar() { if render { withAnimation(.spring) { render = false } } }
  
  func body(content: Content) -> some View {
    content
      .environment(\.openTipJar, openTipJar)
      .overlay {
        GeometryReader { _ in
          ZStack {
            if render {
              Color.black.frame(maxWidth: .infinity, maxHeight: .infinity).opacity(0.7)
                .transition(.opacity.animation(.default))
                .onTapGesture(perform: closeTipJar)
                .zIndex(-1)
              TipJarModal(closeTipJar: closeTipJar)
                .zIndex(1)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
//          .drawingGroup()
          .allowsHitTesting(render)
        }
        .ignoresSafeArea(.all)
      }
  }
}

extension View {
  func tipJarModalProvider() -> some View {
    self.modifier(TipJarModalModifier())
  }
}

private struct OpenTipJarKey: EnvironmentKey {
  static let defaultValue: () -> () = {}
}

extension EnvironmentValues {
  var openTipJar: () -> () {
    get { self[OpenTipJarKey.self] }
    set { self[OpenTipJarKey.self] = newValue }
  }
}
