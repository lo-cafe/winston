//
//  UnseenType.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
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
