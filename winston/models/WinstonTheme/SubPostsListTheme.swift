//
//  SubPostsListTheme.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

struct SubPostsListTheme: Codable, Equatable, Hashable {
  enum CodingKeys: String, CodingKey {
    case theme, spacing, divider, bg
  }
  var theme: PostLinkTheme
  var spacing: CGFloat
  var divider: LineTheme
  var bg: ThemeBG
  
  init(theme: PostLinkTheme, spacing: CGFloat, divider: LineTheme, bg: ThemeBG) {
    self.theme = theme
    self.spacing = spacing
    self.divider = divider
    self.bg = bg
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(theme, forKey: .theme)
    try container.encodeIfPresent(spacing, forKey: .spacing)
    try container.encodeIfPresent(divider, forKey: .divider)
    try container.encodeIfPresent(bg, forKey: .bg)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.postLinks
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.theme = try container.decodeIfPresent(PostLinkTheme.self, forKey: .theme) ?? t.theme
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
    self.divider = try container.decodeIfPresent(LineTheme.self, forKey: .divider) ?? t.divider
    self.bg = try container.decodeIfPresent(ThemeBG.self, forKey: .bg) ?? t.bg
  }
}
