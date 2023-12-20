//
//  GeneralDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Foundation
import Defaults

struct GeneralDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var redditCredentialSelectedID: UUID? = nil
  var redditAPIUserAgent: String = "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)"
  var lastSeenAnnouncementTimeStamp: Int = 0
  var useAuth: Bool = false
  var showingUpsellDict: Dictionary<String, Bool> = .init()
}
