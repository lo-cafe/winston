//
//  ListsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct ListsTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case bg, foreground, dividersColors
  }
  
  var bg: ThemeBG
  var foreground: ThemeForegroundBG
  var dividersColors: ColorSchemes<ThemeColor>
  
  init(bg: ThemeBG, foreground: ThemeForegroundBG, dividersColors: ColorSchemes<ThemeColor>) {
    self.bg = bg
    self.foreground = foreground
    self.dividersColors = dividersColors
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(bg, forKey: .bg)
    try container.encodeIfPresent(foreground, forKey: .foreground)
    try container.encodeIfPresent(dividersColors, forKey: .dividersColors)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.lists
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.bg = try container.decodeIfPresent(ThemeBG.self, forKey: .bg) ?? t.bg
    self.foreground = try container.decodeIfPresent(ThemeForegroundBG.self, forKey: .foreground) ?? t.foreground
    self.dividersColors = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .dividersColors) ?? t.dividersColors
  }
}
