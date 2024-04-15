//
//  GeneralDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Foundation
import Defaults

struct GeneralDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  enum OnboardingState: String, Codable {
    case unknown, dismissed, active
  }
  
  var redditCredentialSelectedID: UUID? = nil
  var onboardingState: OnboardingState = .unknown
  var lastSeenAnnouncementTimeStamp: Int = 0
  var iCloudSyncUserDefaults = true
  var useAuth: Bool = false
  var showingUpsellDict: Dictionary<String, Bool> = .init()
}
