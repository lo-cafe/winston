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


extension ColorSchemes<ThemeColor> {
  func callAsFunction() -> Color {
    Color(light: self.light.color(), dark: self.dark.color())
  }
  
  func color() -> Color {
    Color(light: self.light.color(), dark: self.dark.color())
  }
  
  func uiColor() -> UIColor {
    UIColor(light: self.light.uiColor(), dark: self.dark.uiColor())
  }
}
