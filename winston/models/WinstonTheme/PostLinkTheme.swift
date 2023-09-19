//
//  PostsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

enum UnseenType: Codable, Hashable {
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

struct SubPostsListTheme: Codable, Hashable {
  var theme: PostLinkTheme
  var spacing: CGFloat
  var divider: LineTheme
  var bg: ThemeBG
}

struct PostLinkTheme: Codable, Hashable {
  var type: ThemeObjLayoutType
  var cornerRadius: CGFloat
  var mediaCornerRadius: CGFloat
  var innerPadding: ThemePadding
  var outerHPadding: CGFloat
  var stickyPostBorderColor: LineTheme
  var titleText: ThemeText
  var bodyText: ThemeText
  var badge: BadgeTheme
  var verticalElementsSpacing: CGFloat
  var bg: ThemeForegroundBG
  var unseenType: UnseenType
}
