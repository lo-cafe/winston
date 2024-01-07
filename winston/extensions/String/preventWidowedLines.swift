//
//  preventWidowedLines.swift
//  winston
//
//  Created by Igor Marcossi on 02/01/24.
//

import Foundation

extension String {
  func fixWidowedLines() -> String {
    let zeroWidthSpace: Character = "\u{200B}"
    let spacingForWordWrapping = String(repeating: zeroWidthSpace, count: 6)
    return self + spacingForWordWrapping
  }
}
