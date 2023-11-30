//
//  removeDefaultThemeFromThemes.swift
//  winston
//
//  Created by Igor Marcossi on 30/11/23.
//

import Foundation
import Defaults

func removeDefaultThemeFromThemes() { Defaults[.themesPresets] = Defaults[.themesPresets].filter { $0.id != "default" } }
