//
//  CredentialEditStack.swift
//  winston
//
//  Created by Igor Marcossi on 01/01/24.
//

import SwiftUI

struct CredentialEditStack: View {
  var credential: RedditCredential
  @State private var draftCredential = RedditCredential()
  @State private var waitingForCallback: Bool? = nil
  @State private var navPath = NavigationPath()
  
  @Environment(\.useTheme) private var theme
  
  func renewAccessToken() async {
    let newToken = await draftCredential.getUpToDateToken(forceRenew: true)
    draftCredential.accessToken = newToken
  }
  
  var isDraftValid: Bool { draftCredential.validationStatus != .invalid }
  
  enum Mode: Int, Hashable { case assistant, advanced }
  
  var body: some View {
    NavigationStack(path: $navPath) {
      CredentialEditView(credential: credential, draftCredential: $draftCredential, navPath: $navPath)
        .navigationDestination(for: Mode.self) { mode in
          switch mode {
          case .assistant: CredentialEditAssistantMode()
          case .advanced: CredentialEditAdvancedMode(credential: credential, draftCredential: $draftCredential)
          }
        }
    }
    .onAppear {
      draftCredential = credential
    }
  }
}

