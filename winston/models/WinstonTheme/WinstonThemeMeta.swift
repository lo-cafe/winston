//
//  WinstonThemeMeta.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

struct WinstonThemeMeta: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case name, description, color, icon, author
  }
  
  var name: String
  var description: String
  var color: ThemeColor
  var icon: String
  var author: String
  
  init(name: String = randomWord(), description: String = "", color: ThemeColor = .init(hex: "0B84FE"), icon: String = "paintbrush.fill", author: String = "") {
    self.name = name
    self.description = description
    self.color = color
    self.icon = icon
    self.author = author
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(description, forKey: .description)
    try container.encodeIfPresent(color, forKey: .color)
    try container.encodeIfPresent(icon, forKey: .icon)
    try container.encodeIfPresent(author, forKey: .author)
  }
  
  init(from decoder: Decoder) throws {
    let t = WinstonThemeMeta()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? t.name
    self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? t.description
    self.color = try container.decodeIfPresent(ThemeColor.self, forKey: .color) ?? t.color
    self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? t.icon
    self.author = try container.decodeIfPresent(String.self, forKey: .author) ?? t.author
  }
}
