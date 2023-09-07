//
//  WinstonTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct WinstonTheme: Codable {
  
}

struct TextTheme: Codable {
  var size: CGFloat
  var color: ColorThemes<ThemeColor>
}

struct ColorThemes<Thing: Codable>: Codable {
  var light: Thing
  var dark: Thing
}

enum ThemeObjLayoutType: String, Codable {
  case flat, card
}

enum UnseenType: Codable {
  case dot(ThemeColor), fade
}

struct ThemePadding: Codable {
  var horizontal: CGFloat
  var vertical: CGFloat
}

struct ThemeColor: Codable {
  var hex: String
  var alpha: CGFloat
}

enum ThemeBackgroundType: Codable {
  case material
  case color(ThemeColor)
}

struct CommentsSectionTheme: Codable {
  var commentTheme: CommentTheme
  var commentsSpacing: CGFloat
  var background: ColorThemes<ThemeColor>
}

struct CommentTheme: Codable {
  var type: ThemeObjLayoutType
  var innerPadding: ThemePadding
  var outerPadding: ThemePadding
  var showAvatars: Bool
  var bodyText: TextTheme
  var authorText: TextTheme
  var bodyAuthorSpacing: CGFloat
  var background: ColorThemes<ThemeBackgroundType>
}

struct SubPostsTheme: Codable {
  var postTheme: PostTheme
  var postsSpacing: CGFloat
  var background: ColorThemes<ThemeColor>
}

struct PostTheme: Codable {
  var type: ThemeObjLayoutType
  var cornerRadius: CGFloat
  var mediaCornerRadius: CGFloat
  var innerPadding: ThemePadding
  var outerPadding: ThemePadding
  var stickyPostBorderColor: ThemeColor
  var showAvatars: Bool
  var titleText: TextTheme
  var bodyText: TextTheme
  var authorText: TextTheme
  var statsText: TextTheme
  var verticalElementsSpacing: CGFloat
  var background: ColorThemes<ThemeBackgroundType>
  var unseenType: UnseenType
}

struct PostThemes: Codable {
  var light: PostTheme
  var dark: PostTheme
}
