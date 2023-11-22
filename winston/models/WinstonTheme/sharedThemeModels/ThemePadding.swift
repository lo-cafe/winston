//
//  ThemePadding.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation
import SwiftUI

struct ThemePadding: Codable, Hashable, Equatable {
  var horizontal: CGFloat
  var vertical: CGFloat
  
  func toSize() -> CGSize { CGSize(width: horizontal, height: vertical) }
}

struct ThemeColor: Codable, Hashable, Equatable {
  var hex: String
  var alpha: CGFloat = 1.0
  
  func color() -> Color {
    return Color.hex(hex).opacity(alpha)
  }
}
