//
//  ColorSchemes.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation
import SwiftUI

struct ColorSchemes<Thing: Codable & Hashable>: Codable, Hashable, Equatable {
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
