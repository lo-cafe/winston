//
//  removeLegacySubsAndMultisCache.swift
//  winston
//
//  Created by Igor Marcossi on 30/11/23.
//

import Foundation
import Defaults

func removeLegacySubsAndMultisCache() {
  if Defaults[.multis].count != 0 || Defaults[.subreddits].count != 0 {
    Defaults[.multis] = []
    Defaults[.subreddits] = []
  }
}
