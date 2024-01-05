//
//  SecondaryButton.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI



struct SecondaryActionButtonPrimitive: PrimitiveButtonStyle {
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
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white, lineWidth: 1))
        .foregroundStyle(.primary)
        .fontSize(17, .medium)
        .opacity(configuration.isPressed ? 0.5 : 1)
        .contentShape(Rectangle())
    }
  }
}



struct ActionButtonPrimitive: PrimitiveButtonStyle {
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
        .background(RR(12, Color.accentColor))
        .foregroundStyle(Color.accentColor.antagonist(extreme: true))
        .fontSize(17, .medium)
        .opacity(configuration.isPressed ? 0.75 : 1)
        .contentShape(Rectangle())
    }
  }
}

extension PrimitiveButtonStyle where Self == SecondaryActionButtonPrimitive {
  static var actionSecondary: SecondaryActionButtonPrimitive { SecondaryActionButtonPrimitive() }
  static var action: ActionButtonPrimitive { ActionButtonPrimitive() }
}
