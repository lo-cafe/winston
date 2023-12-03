//
//  SubPostsListTheme.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

struct SubPostsListTheme: Codable, Equatable, Hashable {
  enum CodingKeys: String, CodingKey {
    case theme, spacing, divider, bg, stickyFilters, filterText, filtersPadding
  }
  var theme: PostLinkTheme
  var spacing: CGFloat
  var divider: LineTheme
  var bg: ThemeBG
  var stickyFilters: Bool
  var filterText: ThemeText
  var filtersPadding: CGFloat
  
  init(theme: PostLinkTheme, spacing: CGFloat, divider: LineTheme, bg: ThemeBG, stickyFilters: Bool, filterText: ThemeText, filtersPadding: CGFloat) {
    self.theme = theme
    self.spacing = spacing
    self.divider = divider
    self.bg = bg
    self.stickyFilters = stickyFilters
    self.filterText = filterText
    self.filtersPadding = filtersPadding
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(theme, forKey: .theme)
    try container.encodeIfPresent(spacing, forKey: .spacing)
    try container.encodeIfPresent(divider, forKey: .divider)
    try container.encodeIfPresent(bg, forKey: .bg)
    try container.encodeIfPresent(stickyFilters, forKey: .stickyFilters)
    try container.encodeIfPresent(filterText, forKey: .filterText)
    try container.encodeIfPresent(filtersPadding, forKey: .filtersPadding)

  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.postLinks
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.theme = try container.decodeIfPresent(PostLinkTheme.self, forKey: .theme) ?? t.theme
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
    self.divider = try container.decodeIfPresent(LineTheme.self, forKey: .divider) ?? t.divider
    self.bg = try container.decodeIfPresent(ThemeBG.self, forKey: .bg) ?? t.bg
    self.stickyFilters = try container.decodeIfPresent(Bool.self, forKey: .stickyFilters) ?? t.stickyFilters
    self.filterText = try container.decodeIfPresent(ThemeText.self, forKey: .filterText) ?? t.filterText
    self.filtersPadding = try container.decodeIfPresent(CGFloat.self, forKey: .filtersPadding) ?? t.filtersPadding
  }
}
