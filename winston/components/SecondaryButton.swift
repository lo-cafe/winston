//
//  SecondaryButton.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI

struct SecondaryButton: ButtonStyle {
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
