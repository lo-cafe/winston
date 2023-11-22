//
//  BadgeTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct BadgeTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case avatar, authorText, subColor, flairText, flairBackground, statsText, spacing, forceSubsAsTags
  }
  
  var avatar: AvatarTheme
  var authorText: ThemeText
  var subColor: ColorSchemes<ThemeColor>
  var flairText: ThemeText
  var flairBackground: ColorSchemes<ThemeColor>
  var statsText: ThemeText
  var spacing: CGFloat
  var forceSubsAsTags: Bool
  
  init(avatar: AvatarTheme, authorText: ThemeText, subColor: ColorSchemes<ThemeColor>, flairText: ThemeText, flairBackground: ColorSchemes<ThemeColor>, statsText: ThemeText, spacing: CGFloat, forceSubsAsTags: Bool) {
    self.avatar = avatar
    self.authorText = authorText
    self.subColor = subColor
    self.flairText = flairText
    self.flairBackground = flairBackground
    self.statsText = statsText
    self.spacing = spacing
    self.forceSubsAsTags = forceSubsAsTags
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(avatar, forKey: .avatar)
    try container.encodeIfPresent(authorText, forKey: .authorText)
    try container.encodeIfPresent(subColor, forKey: .subColor)
    try container.encodeIfPresent(flairText, forKey: .flairText)
    try container.encodeIfPresent(flairBackground, forKey: .flairBackground)
    try container.encodeIfPresent(statsText, forKey: .statsText)
    try container.encodeIfPresent(spacing, forKey: .spacing)
    try container.encodeIfPresent(forceSubsAsTags, forKey: .forceSubsAsTags)
  }
  
  init(from decoder: Decoder) throws {
    let t = badgeTheme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.avatar = try container.decodeIfPresent(AvatarTheme.self, forKey: .avatar) ?? t.avatar
    self.authorText = try container.decodeIfPresent(ThemeText.self, forKey: .authorText) ?? t.authorText
    self.subColor = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .subColor) ?? t.subColor
    self.flairText = try container.decodeIfPresent(ThemeText.self, forKey: .flairText) ?? t.flairText
    self.flairBackground = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .flairBackground) ?? t.flairBackground
    self.statsText = try container.decodeIfPresent(ThemeText.self, forKey: .statsText) ?? t.statsText
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
    self.forceSubsAsTags = try container.decodeIfPresent(Bool.self, forKey: .forceSubsAsTags) ?? t.forceSubsAsTags
  }
}
