//
//  BehaviorDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct BehaviorDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var openYoutubeApp: Bool = false
  var openLinksInSafari: Bool = false
  var enableSwipeAnywhere: Bool = false
  var preferenceDefaultFeed: String = "subList"
  var doLiveText: Bool = true
  var iCloudSyncCredentials: Bool = true
}
