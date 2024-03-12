//
//  ThemeColor.swift
//  winston
//
//  Created by Igor Marcossi on 23/01/24.
//

import Foundation
import SwiftUI

class ThemeColorsCache {
  static let shared = ThemeColorsCache()
  var colors: [ThemeColor:Color] = [:]
  var uiColors: [ThemeColor:UIColor] = [:]
  private init() {}
}

struct ThemeColor: Codable, Hashable, Equatable, Identifiable {
  var id: String { "\(self.hex)\(self.alpha)" }
  var hex: String
  var alpha: CGFloat = 1.0
  
  func color() -> Color {
    if let color = ThemeColorsCache.shared.colors[self] { return color }
    let newColor = Color(uiColor: UIColor(hex: hex, alpha: alpha))
    ThemeColorsCache.shared.colors[self] = newColor
    return newColor
  }
  
  func uiColor() -> UIColor {
    if let uiColor = ThemeColorsCache.shared.uiColors[self] { return uiColor }
    let newUiColor = UIColor(hex: hex, alpha: Double(alpha))
    ThemeColorsCache.shared.uiColors[self] = newUiColor
    return newUiColor
  }
}
