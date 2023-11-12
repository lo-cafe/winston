//
//  PostsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

enum UnseenType: Codable, Hashable, Equatable {
  case dot(ColorSchemes<ThemeColor>), fade
  
  func isEqual(_ to: UnseenType) -> Bool {
    if case .dot(_) = self {
      switch to {
      case .dot(_):
        return true
      case .fade:
        return false
      }
    } else {
      switch to {
      case .dot(_):
        return false
      case .fade:
        return true
      }
    }
  }
}

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

struct PostLinkTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case   cornerRadius, mediaCornerRadius, innerPadding, outerHPadding, stickyPostBorderColor, titleText, bodyText, linespacing, badge, verticalElementsSpacing, bg, unseenType, unseenFadeOpacity
  }
  
  var cornerRadius: CGFloat
  var mediaCornerRadius: CGFloat
  var innerPadding: ThemePadding
  var outerHPadding: CGFloat
  var stickyPostBorderColor: LineTheme
  var titleText: ThemeText
  var bodyText: ThemeText
  var linespacing: CGFloat
  var badge: BadgeTheme
  var verticalElementsSpacing: CGFloat
  var bg: ThemeForegroundBG
  var unseenType: UnseenType
  var unseenFadeOpacity: CGFloat
  
    init(cornerRadius: CGFloat, mediaCornerRadius: CGFloat, innerPadding: ThemePadding, outerHPadding: CGFloat, stickyPostBorderColor: LineTheme, titleText: ThemeText, bodyText: ThemeText, linespacing: CGFloat, badge: BadgeTheme, verticalElementsSpacing: CGFloat, bg: ThemeForegroundBG, unseenType: UnseenType, unseenFadeOpacity: CGFloat) {
    self.cornerRadius = cornerRadius
    self.mediaCornerRadius = mediaCornerRadius
    self.innerPadding = innerPadding
    self.outerHPadding = outerHPadding
    self.stickyPostBorderColor = stickyPostBorderColor
    self.titleText = titleText
    self.bodyText = bodyText
    self.linespacing = linespacing
    self.badge = badge
    self.verticalElementsSpacing = verticalElementsSpacing
    self.bg = bg
    self.unseenType = unseenType
    self.unseenFadeOpacity = unseenFadeOpacity
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(cornerRadius, forKey: .cornerRadius)
    try container.encodeIfPresent(mediaCornerRadius, forKey: .mediaCornerRadius)
    try container.encodeIfPresent(innerPadding, forKey: .innerPadding)
    try container.encodeIfPresent(outerHPadding, forKey: .outerHPadding)
    try container.encodeIfPresent(stickyPostBorderColor, forKey: .stickyPostBorderColor)
    try container.encodeIfPresent(titleText, forKey: .titleText)
    try container.encodeIfPresent(bodyText, forKey: .bodyText)
    try container.encodeIfPresent(linespacing, forKey: .linespacing)
    try container.encodeIfPresent(badge, forKey: .badge)
    try container.encodeIfPresent(verticalElementsSpacing, forKey: .verticalElementsSpacing)
    try container.encodeIfPresent(bg, forKey: .bg)
    try container.encodeIfPresent(unseenType, forKey: .unseenType)
    try container.encodeIfPresent(unseenFadeOpacity, forKey: .unseenFadeOpacity)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultTheme.postLinks.theme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.cornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .cornerRadius) ?? t.cornerRadius
    self.mediaCornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .mediaCornerRadius) ?? t.mediaCornerRadius
    self.innerPadding = try container.decodeIfPresent(ThemePadding.self, forKey: .innerPadding) ?? t.innerPadding
    self.outerHPadding = try container.decodeIfPresent(CGFloat.self, forKey: .outerHPadding) ?? t.outerHPadding
    self.stickyPostBorderColor = try container.decodeIfPresent(LineTheme.self, forKey: .stickyPostBorderColor) ?? t.stickyPostBorderColor
    self.titleText = try container.decodeIfPresent(ThemeText.self, forKey: .titleText) ?? t.titleText
    self.bodyText = try container.decodeIfPresent(ThemeText.self, forKey: .bodyText) ?? t.bodyText
    self.linespacing = try container.decodeIfPresent(CGFloat.self, forKey: .linespacing) ?? t.linespacing
    self.badge = try container.decodeIfPresent(BadgeTheme.self, forKey: .badge) ?? t.badge
    self.verticalElementsSpacing = try container.decodeIfPresent(CGFloat.self, forKey: .verticalElementsSpacing) ?? t.verticalElementsSpacing
    self.bg = try container.decodeIfPresent(ThemeForegroundBG.self, forKey: .bg) ?? t.bg
    self.unseenType = try container.decodeIfPresent(UnseenType.self, forKey: .unseenType) ?? t.unseenType
    self.unseenFadeOpacity = try container.decodeIfPresent(CGFloat.self, forKey: .unseenFadeOpacity) ?? t.unseenFadeOpacity
  }
}
