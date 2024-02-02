//
//  ThemeManager.swift
//  winston
//
//  Created by Igor Marcossi on 25/01/24.
//

import Foundation
import Defaults
import SwiftUI

struct InMemoryTheme {
  static let shared = InMemoryTheme()
  @Default(.ThemesDefSettings) private var themesDefSettings
  var currentTheme: WinstonTheme {
    themesDefSettings.themesPresets.first { $0.id == themesDefSettings.selectedThemeID } ?? defaultTheme
  }
}
