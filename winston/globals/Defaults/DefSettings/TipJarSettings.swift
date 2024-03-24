//
//  TipJarSettings.swift
//  winston
//
//  Created by Igor Marcossi on 23/03/24.
//

import SwiftUI
import Defaults

struct TipJarSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var comets = 0
  var tipJarPhase = 0
}
