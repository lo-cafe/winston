//
//  stringFallback.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import Foundation

extension String {
  func fallback(_ str: String) -> String {
    return self.isEmpty ? str : self
    }
}
