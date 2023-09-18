//
//  WinstonTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation
import SwiftUI
import Defaults

struct WinstonTheme: Codable, Identifiable, Hashable, Defaults.Serializable {
  var metadata = WinstonThemeMeta()
  var id: String = UUID().uuidString
  var postLinks: SubPostsListTheme
  var posts: PostTheme
  var comments: CommentsSectionTheme
  var lists: ListsTheme
  var navPanelBG: ThemeForegroundBG
  var tabBarBG: ThemeForegroundBG
  var floatingPanelsBG: ThemeForegroundBG
  var modalsBG: ThemeForegroundBG
  var accentColor: ColorSchemes<ThemeColor>
  
  func duplicate() -> WinstonTheme {
    var copy = self
    copy.id = UUID().uuidString
    copy.metadata.name = randomWord().capitalized
    return copy
  }
}

struct WinstonThemeMeta: Codable, Hashable {
  var name: String = randomWord()
  var description: String = ""
  var color: ThemeColor = .init(hex: "0B84FE")
  var icon: String = "paintbrush.fill"
  var author: String = ""
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
}

struct ThemeText: Codable, Hashable {
  var size: CGFloat
  var color: ColorSchemes<ThemeColor>
  var weight: CodableFontWeight = .regular
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

enum ThemeObjLayoutType: String, Codable, Hashable {
  case flat, card
}

struct ThemePadding: Codable, Hashable {
  var horizontal: CGFloat
  var vertical: CGFloat
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
