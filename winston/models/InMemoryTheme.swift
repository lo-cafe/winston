//
//  ThemeManager.swift
//  winston
//
//  Created by Igor Marcossi on 25/01/24.
//

import Foundation
import Defaults
import SwiftUI

@Observable
class InMemoryTheme {
  static let shared = InMemoryTheme()
  var currentTheme: WinstonTheme = defaultTheme
  var currTask: Task<(), Never>? = nil
  
  init() {
    self.currentTheme = Defaults[.ThemesDefSettings].themesPresets.first { $0.id == Defaults[.ThemesDefSettings].selectedThemeID } ?? defaultTheme
    self.currTask = Task {
      for await value in Defaults.updates(.ThemesDefSettings) {
        self.currentTheme = value.themesPresets.first { $0.id == value.selectedThemeID } ?? defaultTheme
      }
    }
  }
  
  deinit {
    currTask?.cancel()
  }
}
