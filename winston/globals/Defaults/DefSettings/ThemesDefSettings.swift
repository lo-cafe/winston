//
//  ThemesDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct ThemesDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var themesPresets: [WinstonTheme] = []
  var selectedThemeID: String = "default"
}
