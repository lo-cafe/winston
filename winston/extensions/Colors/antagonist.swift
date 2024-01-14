//
//  contrastColor.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import SwiftUI

extension Color {
  func antagonist(threshold: Double = 0.7, extreme: Bool = false) -> Color {
    return self.brightness() > threshold ? extreme ? .black : self.darken(0.65) : extreme ? .white : self.lighten(0.9)
  }
}
