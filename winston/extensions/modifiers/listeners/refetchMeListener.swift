//
//  refetchMeListener.swift
//  winston
//
//  Created by Igor Marcossi on 13/12/23.
//

import SwiftUI
import Defaults

struct RefetchMeListenerModifier: ViewModifier {
  @Default(.GeneralDefSettings) private var generalDefSettings
  func body(content: Content) -> some View {
    content
      .onChange(of: generalDefSettings.redditCredentialSelectedID) { newCredID in
        if let newCredID, let newCred = RedditCredentialsManager.getById(newCredID) {
          RedditCredentialsManager.shared.updateMe(altCred: newCred)
        }
      }
  }
}

extension View {
  func refetchMeListener() -> some View {
    self.modifier(RefetchMeListenerModifier())
  }
}
