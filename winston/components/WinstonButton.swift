//
//  WinstonButton.swift
//  winston
//
//  Created by Igor Marcossi on 06/01/24.
//

import SwiftUI

struct WinstonButtonConfig {
  static let success = Self.primary()
  static func success(fullWidth: Bool = false, cornerRadius: Double = 12, fontSize: Double = 17) -> WinstonButtonConfig {
    WinstonButtonConfig(fullWidth: fullWidth, bgColor: .green, textColor: .white, cornerRadius: cornerRadius, fontSize: fontSize, fontWeight: .medium, animation: .easeIn(duration: 0.135))
  }
  static let primary = Self.primary()
  static func primary(fullWidth: Bool = false, cornerRadius: Double = 12, fontSize: Double = 17) -> WinstonButtonConfig {
    WinstonButtonConfig(fullWidth: fullWidth, bgColor: .accentColor, textColor: .white, cornerRadius: cornerRadius, fontSize: fontSize, fontWeight: .medium, animation: .easeIn(duration: 0.135))
  }
  static let secondary = Self.secondary()
  static func secondary(fullWidth: Bool = false, cornerRadius: Double = 12, fontSize: Double = 17) -> WinstonButtonConfig {
    WinstonButtonConfig(fullWidth: fullWidth, bgColor: .acceptablePrimary, textColor: .primary, cornerRadius: cornerRadius, fontSize: fontSize, fontWeight: .medium, animation: .easeIn(duration: 0.135))
  }
  
  var fullWidth: Bool
  var bgColor: Color
  var textColor: Color?
  var cornerRadius: Double
  var fontSize: Double
  var fontWeight: Font.Weight
  var animation: Animation
}

struct WinstonButton<C: View>: View {
  var action: () -> ()
  @ViewBuilder var label: () -> C
  var config: WinstonButtonConfig
  
  init(config: WinstonButtonConfig = .primary, _ action: @escaping () -> Void, label: @escaping () -> C) {
    self.action = action
    self.label = label
    self.config = config
  }
  
  @State private var pressed = false
  @Environment(\.colorScheme) private var cs
  var body: some View {
    HStack {
      label()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .frame(maxWidth: config.fullWidth ? .infinity : nil)
    .background(RR(config.cornerRadius, config.bgColor))
    .foregroundStyle(config.textColor ?? config.bgColor.antagonist(extreme: true))
    .brightness(pressed ? cs == .dark ? 0.5 : -1 : 0)
    .fontSize(config.fontSize, config.fontWeight)
    .contentShape(Rectangle())
    .onTapGesture { action() }
    .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 20, perform: {}) { val in
      withAnimation(config.animation) { pressed = val }
    }
  }
}
