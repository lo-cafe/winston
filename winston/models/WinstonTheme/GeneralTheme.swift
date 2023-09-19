//
//  GeneralTheme.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation

struct GeneralTheme: Codable, Hashable {
  var navPanelBG: ThemeForegroundBG
  var tabBarBG: ThemeForegroundBG
  var floatingPanelsBG: ThemeForegroundBG
  var modalsBG: ThemeForegroundBG
  var accentColor: ColorSchemes<ThemeColor>
}
