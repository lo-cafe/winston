//
//  BadgeTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct BadgeTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case avatar, authorText, flairText, flairBackground, statsText, spacing
  }
  
  var avatar: AvatarTheme
  var authorText: ThemeText
  var flairText: ThemeText
  var flairBackground: ColorSchemes<ThemeColor>
  var statsText: ThemeText
  var spacing: CGFloat
  
  init(avatar: AvatarTheme, authorText: ThemeText, flairText: ThemeText, flairBackground: ColorSchemes<ThemeColor>, statsText: ThemeText, spacing: CGFloat) {
    self.avatar = avatar
    self.authorText = authorText
    self.flairText = flairText
    self.flairBackground = flairBackground
    self.statsText = statsText
    self.spacing = spacing
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(avatar, forKey: .avatar)
    try container.encodeIfPresent(authorText, forKey: .authorText)
    try container.encodeIfPresent(flairText, forKey: .flairText)
    try container.encodeIfPresent(flairBackground, forKey: .flairBackground)
    try container.encodeIfPresent(statsText, forKey: .statsText)
    try container.encodeIfPresent(spacing, forKey: .spacing)
  }
  
  init(from decoder: Decoder) throws {
    let t = badgeTheme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.avatar = try container.decodeIfPresent(AvatarTheme.self, forKey: .avatar) ?? t.avatar
    self.authorText = try container.decodeIfPresent(ThemeText.self, forKey: .authorText) ?? t.authorText
    self.flairText = try container.decodeIfPresent(ThemeText.self, forKey: .flairText) ?? t.flairText
    self.flairBackground = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .flairBackground) ?? t.flairBackground
    self.statsText = try container.decodeIfPresent(ThemeText.self, forKey: .statsText) ?? t.statsText
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
  }
}
