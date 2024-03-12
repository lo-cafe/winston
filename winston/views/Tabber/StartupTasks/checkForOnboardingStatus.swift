//
//  checkForOnboardingStatus.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import Foundation
import Defaults

func checkForOnboardingStatus() {
  var open = false
  open = switch Defaults[.GeneralDefSettings].onboardingState {
  case .active: true
  case .unknown: RedditCredentialsManager.shared.credentials.isEmpty
  case .dismissed: false
  }
  if open { Nav.present(.onboarding) }
}
