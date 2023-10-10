//
//  CommentsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct CommentsSectionTheme: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case theme, spacing, divider
  }
  
  var theme: CommentTheme
  var spacing: CGFloat
  var divider: LineTheme
  
  init(theme: CommentTheme, spacing: CGFloat, divider: LineTheme) {
    self.theme = theme
    self.spacing = spacing
    self.divider = divider
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(theme, forKey: .theme)
    try container.encodeIfPresent(spacing, forKey: .spacing)
    try container.encodeIfPresent(divider, forKey: .divider)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.comments
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.theme = try container.decodeIfPresent(CommentTheme.self, forKey: .theme) ?? t.theme
    self.spacing = try container.decodeIfPresent(CGFloat.self, forKey: .spacing) ?? t.spacing
    self.divider = try container.decodeIfPresent(LineTheme.self, forKey: .divider) ?? t.divider
  }
}

struct CommentTheme: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case innerPadding, outerHPadding, repliesSpacing, indentCurve, indentColor, cornerRadius, badge, bodyText, bodyAuthorSpacing, bg, loadMoreInnerPadding, loadMoreOuterTopPadding, loadMoreText, loadMoreBackground, unseenDot
  }
  
  var innerPadding: ThemePadding
  var outerHPadding: CGFloat
  var repliesSpacing: CGFloat
  var indentCurve: CGFloat
  var indentColor: ColorSchemes<ThemeColor>
  var cornerRadius: CGFloat
  var badge: BadgeTheme
  var bodyText: ThemeText
  var bodyAuthorSpacing: CGFloat
  var bg: ColorSchemes<ThemeColor>
    
  var loadMoreInnerPadding: ThemePadding
  var loadMoreOuterTopPadding: CGFloat
  var loadMoreText : ThemeText
  var loadMoreBackground : ColorSchemes<ThemeColor>
  
  var unseenDot : ColorSchemes<ThemeColor>
  
  init(innerPadding: ThemePadding, outerHPadding: CGFloat, repliesSpacing: CGFloat, indentCurve: CGFloat, indentColor: ColorSchemes<ThemeColor>, cornerRadius: CGFloat, badge: BadgeTheme, bodyText: ThemeText, bodyAuthorSpacing: CGFloat, bg: ColorSchemes<ThemeColor>, loadMoreInnerPadding: ThemePadding, loadMoreOuterTopPadding: CGFloat, loadMoreText : ThemeText, loadMoreBackground : ColorSchemes<ThemeColor>, unseenDot : ColorSchemes<ThemeColor>) {
    self.innerPadding = innerPadding
    self.outerHPadding = outerHPadding
    self.repliesSpacing = repliesSpacing
    self.indentCurve = indentCurve
    self.indentColor = indentColor
    self.cornerRadius = cornerRadius
    self.badge = badge
    self.bodyText = bodyText
    self.bodyAuthorSpacing = bodyAuthorSpacing
    self.bg = bg
    self.loadMoreInnerPadding = loadMoreInnerPadding
    self.loadMoreOuterTopPadding = loadMoreOuterTopPadding
    self.loadMoreText = loadMoreText
    self.loadMoreBackground = loadMoreBackground
    self.unseenDot = unseenDot
    
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(innerPadding, forKey: .innerPadding)
    try container.encodeIfPresent(outerHPadding, forKey: .outerHPadding)
    try container.encodeIfPresent(repliesSpacing, forKey: .repliesSpacing)
    try container.encodeIfPresent(indentCurve, forKey: .indentCurve)
    try container.encodeIfPresent(indentColor, forKey: .indentColor)
    try container.encodeIfPresent(cornerRadius, forKey: .cornerRadius)
    try container.encodeIfPresent(badge, forKey: .badge)
    try container.encodeIfPresent(bodyText, forKey: .bodyText)
    try container.encodeIfPresent(bodyAuthorSpacing, forKey: .bodyAuthorSpacing)
    try container.encodeIfPresent(bg, forKey: .bg)
    try container.encodeIfPresent(loadMoreInnerPadding, forKey: .loadMoreInnerPadding)
    try container.encodeIfPresent(loadMoreOuterTopPadding, forKey: .loadMoreOuterTopPadding)
    try container.encodeIfPresent(loadMoreText, forKey: .loadMoreText)
    try container.encodeIfPresent(loadMoreBackground, forKey: .loadMoreBackground)
    try container.encodeIfPresent(unseenDot, forKey: .unseenDot)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.comments.theme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.innerPadding = try container.decodeIfPresent(ThemePadding.self, forKey: .innerPadding) ?? t.innerPadding
    self.outerHPadding = try container.decodeIfPresent(CGFloat.self, forKey: .outerHPadding) ?? t.outerHPadding
    self.repliesSpacing = try container.decodeIfPresent(CGFloat.self, forKey: .repliesSpacing) ?? t.repliesSpacing
    self.indentCurve = try container.decodeIfPresent(CGFloat.self, forKey: .indentCurve) ?? t.indentCurve
    self.indentColor = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .indentColor) ?? t.indentColor
    self.cornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .cornerRadius) ?? t.cornerRadius
    self.badge = try container.decodeIfPresent(BadgeTheme.self, forKey: .badge) ?? t.badge
    self.bodyText = try container.decodeIfPresent(ThemeText.self, forKey: .bodyText) ?? t.bodyText
    self.bodyAuthorSpacing = try container.decodeIfPresent(CGFloat.self, forKey: .bodyAuthorSpacing) ?? t.bodyAuthorSpacing
    self.bg = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .bg) ?? t.bg
    self.loadMoreInnerPadding = try container.decodeIfPresent(ThemePadding.self, forKey: .loadMoreInnerPadding) ?? t.loadMoreInnerPadding
    self.loadMoreOuterTopPadding = try container.decodeIfPresent(CGFloat.self, forKey: .loadMoreOuterTopPadding) ?? t.loadMoreOuterTopPadding
    self.loadMoreText = try container.decodeIfPresent(ThemeText.self, forKey: .loadMoreText) ?? t.loadMoreText
    self.loadMoreText = try container.decodeIfPresent(ThemeText.self, forKey: .loadMoreText) ?? t.loadMoreText
    self.loadMoreBackground = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .loadMoreBackground) ?? t.loadMoreBackground
    self.unseenDot = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .unseenDot) ?? t.unseenDot
  }
}
