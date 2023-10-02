//
//  WinstonTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation
import SwiftUI
import Defaults

struct WinstonTheme: Codable, Identifiable, Hashable, Equatable, Defaults.Serializable {
  enum CodingKeys: String, CodingKey {
    case metadata, id, postLinks, posts, comments, lists, general
  }
  
  var metadata: WinstonThemeMeta
  var id: String
  var postLinks: SubPostsListTheme
  var posts: PostTheme
  var comments: CommentsSectionTheme
  var lists: ListsTheme
  var general: GeneralTheme
  
  func duplicate() -> WinstonTheme {
    var copy = self
    copy.id = UUID().uuidString
    if copy.metadata.name == "Default" { copy.metadata.name = randomWord().capitalized }
    return copy
  }
  
  init(
    metadata: WinstonThemeMeta = WinstonThemeMeta(),
    id: String = UUID().uuidString,
    postLinks: SubPostsListTheme,
    posts: PostTheme,
    comments: CommentsSectionTheme,
    lists: ListsTheme,
    general: GeneralTheme
  ) {
    self.metadata = metadata
    self.id = id
    self.postLinks = postLinks
    self.posts = posts
    self.comments = comments
    self.lists = lists
    self.general = general
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(metadata, forKey: .metadata)
    try container.encodeIfPresent(id, forKey: .id)
    try container.encodeIfPresent(postLinks, forKey: .postLinks)
    try container.encodeIfPresent(posts, forKey: .posts)
    try container.encodeIfPresent(comments, forKey: .comments)
    try container.encodeIfPresent(lists, forKey: .lists)
    try container.encodeIfPresent(general, forKey: .general)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.metadata = try container.decode(WinstonThemeMeta.self, forKey: .metadata)
    self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
    self.postLinks = try container.decodeIfPresent(SubPostsListTheme.self, forKey: .postLinks) ?? defaultTheme.postLinks
    self.posts = try container.decodeIfPresent(PostTheme.self, forKey: .posts) ?? defaultTheme.posts
    self.comments = try container.decodeIfPresent(CommentsSectionTheme.self, forKey: .comments) ?? defaultTheme.comments
    self.lists = try container.decodeIfPresent(ListsTheme.self, forKey: .lists) ?? defaultTheme.lists
    self.general = try container.decodeIfPresent(GeneralTheme.self, forKey: .general) ?? defaultTheme.general
  }
}

struct WinstonThemeMeta: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case name, description, color, icon, author
  }
  
  var name: String
  var description: String
  var color: ThemeColor
  var icon: String
  var author: String
  
  init(name: String = randomWord(), description: String = "", color: ThemeColor = .init(hex: "0B84FE"), icon: String = "paintbrush.fill", author: String = "") {
    self.name = name
    self.description = description
    self.color = color
    self.icon = icon
    self.author = author
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(description, forKey: .description)
    try container.encodeIfPresent(color, forKey: .color)
    try container.encodeIfPresent(icon, forKey: .icon)
    try container.encodeIfPresent(author, forKey: .author)
  }
  
  init(from decoder: Decoder) throws {
    let t = WinstonThemeMeta()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? t.name
    self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? t.description
    self.color = try container.decodeIfPresent(ThemeColor.self, forKey: .color) ?? t.color
    self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? t.icon
    self.author = try container.decodeIfPresent(String.self, forKey: .author) ?? t.author
  }
}

// ---- ELDER ONES ---- //

enum CodableFontWeight: Codable, Hashable, CaseIterable {
  case light, regular, medium, semibold, bold
  
  var t: Font.Weight {
    switch self {
    case .light:
      return .light
    case .regular:
      return .regular
    case .medium:
      return .medium
    case .semibold:
      return .semibold
    case .bold:
      return .bold
//    case .heavy:
//      return .heavy
//    case .black:
//      return .black
    }
  }
  
  var ut: UIFont.Weight {
    switch self {
    case .light:
      return .light
    case .regular:
      return .regular
    case .medium:
      return .medium
    case .semibold:
      return .semibold
    case .bold:
      return .bold
//    case .heavy:
//      return .heavy
//    case .black:
//      return .black
    }
  }
}

struct ThemeText: Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case size, color, weight
  }
  
  var size: CGFloat
  var color: ColorSchemes<ThemeColor>
  var weight: CodableFontWeight = .regular
  
  init(size: CGFloat, color: ColorSchemes<ThemeColor>, weight: CodableFontWeight = .regular) {
    self.size = size
    self.color = color
    self.weight = weight
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(color, forKey: .color)
    try container.encodeIfPresent(weight, forKey: .weight)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.size = try container.decodeIfPresent(CGFloat.self, forKey: .size) ?? 16
    self.color = try container.decodeIfPresent(ColorSchemes<ThemeColor>.self, forKey: .color) ?? themeFontPrimary
    self.weight = try container.decodeIfPresent(CodableFontWeight.self, forKey: .weight) ?? .regular
  }
}

struct ColorSchemes<Thing: Codable & Hashable>: Codable, Hashable {
  var light: Thing
  var dark: Thing
  
  func cs(_ cs: ColorScheme) -> Thing {
    switch cs {
    case .dark:
      return self.dark
    case .light:
      return self.light
    @unknown default:
      return self.light
    }
  }
}

struct ThemePadding: Codable, Hashable {
  var horizontal: CGFloat
  var vertical: CGFloat
  
  func toSize() -> CGSize { CGSize(width: horizontal, height: vertical) }
}

struct ThemeColor: Codable, Hashable {
  var hex: String
  var alpha: CGFloat = 1.0
  
  func color() -> Color {
    return Color.hex(hex).opacity(alpha)
  }
}

struct ThemeForegroundBG: Codable, Hashable {
  var blurry: Bool
  var color: ColorSchemes<ThemeColor>
}

enum ThemeBG: Codable, Hashable {
  case color(ColorSchemes<ThemeColor>)
  case img(ColorSchemes<String>)
  
  func isEqual(_ to: ThemeBG) -> Bool {
    if case .color(_) = self {
      switch to {
      case .color(_):
        return true
      case .img(_):
        return false
      }
    } else {
      switch to {
      case .color(_):
        return false
      case .img(_):
        return true
      }
    }
  }
}
