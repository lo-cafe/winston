//
//  SecondaryButton.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI



struct SecondaryOutlinedActionButtonPrimitive: PrimitiveButtonStyle {
  var fullWidth = false
  public func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(Style(fullWidth: fullWidth))
  }
  
  struct Style: ButtonStyle {
    var fullWidth: Bool
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.primary, lineWidth: 1))
        .foregroundStyle(.primary)
        .fontSize(17, .medium)
        .opacity(configuration.isPressed ? 0.5 : 1)
        .contentShape(Rectangle())
    }
  }
}



struct ActionButtonPrimitive: PrimitiveButtonStyle {
  var fullWidth = false
  var color: Color = .accentColor
  var textColor: Color? = nil
  public func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(Style(fullWidth: fullWidth, color: color, textColor: textColor))
  }
  
  struct Style: ButtonStyle {
    var fullWidth: Bool
    var color: Color = .accentColor
    var textColor: Color? = nil
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .background(RR(12, color))
        .foregroundStyle(textColor ?? color.antagonist(extreme: true))
        .fontSize(17, .medium)
        .opacity(configuration.isPressed ? 0.75 : 1)
        .contentShape(Rectangle())
    }
  }
}

extension PrimitiveButtonStyle where Self == SecondaryOutlinedActionButtonPrimitive {
  static var actionOutlined: SecondaryOutlinedActionButtonPrimitive { SecondaryOutlinedActionButtonPrimitive() }
}

extension PrimitiveButtonStyle where Self == ActionButtonPrimitive {
  static var action: ActionButtonPrimitive { ActionButtonPrimitive() }
  static func action(fullWidth: Bool = true) -> ActionButtonPrimitive { ActionButtonPrimitive(fullWidth: fullWidth) }
  static var actionSecondary: ActionButtonPrimitive { ActionButtonPrimitive(color: .acceptablePrimary, textColor: .primary) }
  static func actionSecondary(fullWidth: Bool = true) -> ActionButtonPrimitive { ActionButtonPrimitive(fullWidth: fullWidth, color: .acceptablePrimary, textColor: .primary) }
}
