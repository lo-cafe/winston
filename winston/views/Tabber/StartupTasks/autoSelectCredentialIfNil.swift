//
//  autoSelectCredentialIfNil.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation
import Defaults

func autoSelectCredentialIfNil(_ selectedCredID: UUID? = Defaults[.redditCredentialSelectedID]) {
  if selectedCredID == nil {
    let validCreds = RedditCredentialsManager.shared.validCredentials
    if validCreds.count > 0 { Defaults[.redditCredentialSelectedID] = validCreds[0].id }
  }
}
