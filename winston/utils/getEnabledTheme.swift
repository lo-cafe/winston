//
//  getEnabledTheme.swift
//  winston
//
//  Created by Igor Marcossi on 01/10/23.
//

import Foundation
import Defaults

func getEnabledTheme() -> WinstonTheme {
 return Defaults[.themesPresets].first(where: { $0.id == Defaults[.selectedThemeID] }) ?? defaultTheme
}
