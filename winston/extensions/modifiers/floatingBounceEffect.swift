//
//  floatBounceEffect.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import SwiftUI
import Combine

typealias AutoconnectableTimer = Publishers.Autoconnect< Timer.TimerPublisher>

/// A view modifier to apply a themed background to a list row.
struct FloatingBounceEffectModifier: ViewModifier {
  static let floatOffsetVariationAmount: Double = 10
  static let floatingDuration: Double = 3
  static func getTimer() -> AutoconnectableTimer {
    return Timer.publish(every: Self.floatingDuration, on: .main, in: .common).autoconnect()
  }

  var disabled: Bool = false
  @State private var floatOffset: CGSize = .zero
  @State private var timer: AutoconnectableTimer
  
  init(disabled: Bool) {
    self.disabled = disabled
    self._timer = .init(initialValue: Self.getTimer())
  }
  
  func stopTimer() { timer.upstream.connect().cancel() }
  
  func restartTimer() { float(); timer = Self.getTimer() }
  
  func float() {
    var newHeight = (Self.floatOffsetVariationAmount / 2) * (floatOffset.height < 0 ? 1 : -1)
    let variation = CGFloat.random(in: 0...2)
    newHeight -= variation * (newHeight > 0 ? 1 : -1)
    withAnimation(.easeInOut(duration: Self.floatingDuration)) {
      floatOffset = .init(width: 0, height: newHeight)
    }
  }
  
  func body(content: Content) -> some View {
    content
      .offset(floatOffset)
      .onChange(of: disabled) {
        if $0 {
          stopTimer()
          withAnimation(.spring) { floatOffset = .zero }
          return
        }
        restartTimer()
      }
      .onAppear { float() }
      .onReceive(timer) { _ in if !disabled { float() } }
  }
}

extension View {
  func floatingBounceEffect(disabled: Bool = false) -> some View {
    self.modifier(FloatingBounceEffectModifier(disabled: disabled))
  }
}
