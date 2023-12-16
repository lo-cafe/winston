//
//  getEnabledTheme.swift
//  winston
//
//  Created by Igor Marcossi on 01/10/23.
//

import Foundation
import Defaults

func getEnabledTheme() -> WinstonTheme {
  return Defaults[.ThemesDefSettings].themesPresets.first(where: { $0.id == Defaults[.ThemesDefSettings].selectedThemeID }) ?? defaultTheme
}
