//
//  AppearanceDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct AppearanceDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var replyModalBlurBackground: Bool = true
  var newPostModalBlurBackground: Bool = true
  var showUsernameInTabBar: Bool = false
  var disableAlphabetLettersSectionsInSubsList: Bool = false
  var themeStoreTint: Bool = true
  var shinyTextAndButtons: Bool = false
}
