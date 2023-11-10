//
//  PostTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct PostTheme: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case padding, spacing, badge, bg, commentsDistance, titleText, bodyText, linespacing
  }

  var padding: ThemePadding
  var spacing: CGFloat
  var badge: BadgeTheme
  var bg: ThemeBG
  var commentsDistance: CGFloat
  var titleText: ThemeText
  var bodyText: ThemeText
  var linespacing: CGFloat
  
  init(padding: ThemePadding, spacing: CGFloat, badge: BadgeTheme, bg: ThemeBG, commentsDistance: CGFloat, titleText: ThemeText, bodyText: ThemeText, linespacing: CGFloat) {
    self.padding = padding
    self.spacing = spacing
    self.badge = badge
    self.bg = bg
    self.commentsDistance = commentsDistance
    self.titleText = titleText
    self.bodyText = bodyText
    self.linespacing = linespacing
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(padding, forKey: .padding)
    try container.encodeIfPresent(spacing, forKey: .spacing)
    try container.encodeIfPresent(badge, forKey: .badge)
    try container.encodeIfPresent(bg, forKey: .bg)
    try container.encodeIfPresent(commentsDistance, forKey: .commentsDistance)
    try container.encodeIfPresent(titleText, forKey: .titleText)
    try container.encodeIfPresent(bodyText, forKey: .bodyText)
    try container.encodeIfPresent(linespacing, forKey: .linespacing)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.posts
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.padding = try container.decodeIfPresent(ThemePadding.self, forKey: .padding) ?? t.padding
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
    self.badge = try container.decodeIfPresent(BadgeTheme.self, forKey: .badge) ?? t.badge
    self.bg = try container.decodeIfPresent(ThemeBG.self, forKey: .bg) ?? t.bg
    self.commentsDistance = try container.decodeIfPresent(CGFloat.self, forKey: .commentsDistance) ?? t.commentsDistance
    self.titleText = try container.decodeIfPresent(ThemeText.self, forKey: .titleText) ?? t.titleText
    self.bodyText = try container.decodeIfPresent(ThemeText.self, forKey: .bodyText) ?? t.bodyText
    self.linespacing = try container.decodeIfPresent(CGFloat.self, forKey: .linespacing) ?? t.linespacing
  }
}
