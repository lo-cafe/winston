//
//  PostTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct PostTheme: Codable, Hashable {
  var padding: ThemePadding
  var spacing: CGFloat
  var badge: BadgeTheme
  var bg: ThemeBG
  var commentsDistance: CGFloat
  var titleText: ThemeText
  var bodyText: ThemeText
}
