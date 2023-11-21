//
//  ThemeText.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

struct ThemeText: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case size, color, weight
  }
  
  var size: CGFloat
  var color: ColorSchemes<ThemeColor>
  var weight: CodableFontWeight = .regular
  
  init(size: CGFloat, color: ColorSchemes<ThemeColor>, weight: CodableFontWeight = .regular) {
    self.size = size
    self.color = color
    self.weight = weight
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(color, forKey: .color)
    try container.encodeIfPresent(weight, forKey: .weight)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.size = try container.decodeIfPresent(CGFloat.self, forKey: .size) ?? 16
    self.color = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .color) ?? themeFontPrimary
    self.weight = try container.decodeIfPresent(CodableFontWeight.self, forKey: .weight) ?? .regular
  }
}
