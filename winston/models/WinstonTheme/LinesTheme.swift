//
//  LinesTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

enum LineTypeTheme: Codable, Hashable, CaseIterable {
  case line, fancy, no
}

struct LineTheme: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case style, thickness, color
  }
  var style: LineTypeTheme?
  var thickness: CGFloat
  var color: ColorSchemes<ThemeColor>

  init(style: LineTypeTheme? = nil, thickness: CGFloat, color: ColorSchemes<ThemeColor>) {
    self.style = style
    self.thickness = thickness
    self.color = color
    }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(style, forKey: .style)
    try container.encodeIfPresent(thickness, forKey: .thickness)
    try container.encodeIfPresent(color, forKey: .color)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.style = try container.decodeIfPresent(LineTypeTheme?.self, forKey: .style) ?? .no
    self.thickness = try container.decodeIfPresent(CGFloat.self, forKey: .thickness) ?? 0.5
    self.color = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .color) ?? defaultThemeDividerColor
  }
}
