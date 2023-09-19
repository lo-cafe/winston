//
//  CommentsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct CommentsSectionTheme: Codable, Hashable {
  var theme: CommentTheme
  var spacing: CGFloat
  var divider: LineTheme
//  var bg: ThemeBG
}

struct CommentTheme: Codable, Hashable {
  var type: ThemeObjLayoutType
  var innerPadding: ThemePadding
  var outerHPadding: CGFloat
  var repliesSpacing: CGFloat
  var indentCurve: CGFloat
  var cornerRadius: CGFloat
  var badge: BadgeTheme
  var bodyText: ThemeText
  var bodyAuthorSpacing: CGFloat
  var bg: ColorSchemes<ThemeColor>
}
