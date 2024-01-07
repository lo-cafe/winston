//
//  ColorSchemes.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation
import SwiftUI

struct ColorSchemes<Thing: Codable & Hashable>: Codable, Hashable, Equatable {
  var light: Thing
  var dark: Thing
  
  func cs(_ cs: ColorScheme) -> Thing {
    switch cs {
    case .dark:
      return self.dark
    case .light:
      return self.light
    @unknown default:
      return self.light
    }
  }
}

private func getSystemBrighterColor(_ hex: String) -> Color? {
  return switch hex.lowercased() {
    case "1c1c1e": Color.hex("2c2c2e")
    case "000000": Color.hex("1c1c1e")
    default: nil
    }
}


extension ColorSchemes<ThemeColor> {
  func callAsFunction(brighter: Bool = false, brighterRatio: Double = 0.11) -> Color { self.color(brighter: brighter, brighterRatio: brighterRatio) }
  
  func color(brighter: Bool = false, brighterRatio: Double = 0.11) -> Color {
    let systemBrighter = brighter ? getSystemBrighterColor(self.dark.hex) : nil
    return Color(light: self.light.color(), dark: systemBrighter ?? self.dark.color().lighten(brighter ? brighterRatio : 0))
  }
  
  func uiColor(brighter: Bool = false, brighterRatio: Double = 0.11) -> UIColor {
    let systemBrighter = brighter ? getSystemBrighterColor(self.dark.hex) : nil
    let finalDarkColor = systemBrighter == nil ? self.dark.uiColor().lighter(by: brighter ? brighterRatio : 0) : UIColor(systemBrighter!)
    return UIColor(light: self.light.uiColor(), dark: finalDarkColor)
  }
}
