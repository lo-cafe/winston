//
//  CredentialOnly.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI

struct WithCredentialOnly<Content: View>: View {
  let credential: RedditCredential?
  @Environment(\.changeAppTabWithPath) var changeAppTabWithPath
  @ViewBuilder let content: () -> Content
    var body: some View {
      if !(credential?.isAuthorized ?? false) {
        VStack(spacing: 20) {
          VStack(spacing: 12) {
            Image(systemName: credential == nil ? "questionmark.key.filled" : "key.slash.fill")
              .fontSize(64, .bold)
              .opacity(0.5)
            VStack(spacing: 4) {
              Text(credential == nil ? "No credential" : "Credential invalid")
                .fontSize(24, .bold)
                .opacity(0.5)
              Text("We can't load this page 😔").opacity(0.35)
            }
          }
          Button("Go to credentials settings", systemImage: "gear") {
            changeAppTabWithPath(.settings, .init([SettingsPages.credentials]))
          }
          .buttonStyle(SecondaryButton())
        }
        .compositingGroup()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        content()
      }
    }
}

