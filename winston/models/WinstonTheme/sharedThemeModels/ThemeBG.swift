//
//  ThemeBG.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

enum ThemeBG: Codable, Hashable, Equatable {
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
