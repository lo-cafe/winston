//
//  SecondaryButton.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI



struct SecondaryActionButtonPrimitive: PrimitiveButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(Style())
  }
  
  struct Style: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white, lineWidth: 1))
        .foregroundStyle(.primary)
        .fontSize(17, .medium)
        .opacity(configuration.isPressed ? 0.25 : 0.5)
        .contentShape(Rectangle())
    }
  }
}



struct ActionButtonPrimitive: PrimitiveButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(Style())
  }
  
  struct Style: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
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
