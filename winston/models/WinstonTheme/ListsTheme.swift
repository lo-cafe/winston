//
//  ListsTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct ListsTheme: Codable, Hashable {
  var bg: ThemeBG
  var foreground: ThemeForegroundBG
  var dividersColors: ColorSchemes<ThemeColor>
}
