//
//  BadgeTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct BadgeTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case avatar, authorText, statsText, spacing
  }
  
  var avatar: AvatarTheme
  var authorText: ThemeText
  var statsText: ThemeText
  var spacing: CGFloat
  
  init(avatar: AvatarTheme, authorText: ThemeText, statsText: ThemeText, spacing: CGFloat) {
    self.avatar = avatar
    self.authorText = authorText
    self.statsText = statsText
    self.spacing = spacing
    }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(avatar, forKey: .avatar)
    try container.encodeIfPresent(authorText, forKey: .authorText)
    try container.encodeIfPresent(statsText, forKey: .statsText)
    try container.encodeIfPresent(spacing, forKey: .spacing)
  }
  
  init(from decoder: Decoder) throws {
    let t = badgeTheme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.avatar = try container.decodeIfPresent(AvatarTheme.self, forKey: .avatar) ?? t.avatar
    self.authorText = try container.decodeIfPresent(ThemeText.self, forKey: .authorText) ?? t.authorText
    self.statsText = try container.decodeIfPresent(ThemeText.self, forKey: .statsText) ?? t.statsText
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
  }
}
