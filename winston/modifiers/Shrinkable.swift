//
//  Shrinkable.swift
//  winston
//
//  Created by Igor Marcossi on 03/07/23.
//

import Foundation
import SwiftUI

struct ShrinkableBtnStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        .buttonStyle(.plain)
        .scaleEffect(configuration.isPressed ? 0.975 : 1)
        .animation(spring, value: configuration.isPressed)
    }
}
