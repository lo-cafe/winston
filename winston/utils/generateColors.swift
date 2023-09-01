//
//  generateColors.swift
//  winston
//
//  Created by Daniel Inama on 24/08/23.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Color {
  init(r: Double, g: Double, b: Double){
    self.init(
      .sRGB,
      red: r,
      green: g,
      blue: b
    )
  }
}
