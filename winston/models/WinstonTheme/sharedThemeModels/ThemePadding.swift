//
//  ThemePadding.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation

struct ThemePadding: Codable, Hashable, Equatable {
  var horizontal: CGFloat
  var vertical: CGFloat
  
  func toSize() -> CGSize { CGSize(width: horizontal, height: vertical) }
}

