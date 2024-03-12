//
//  CredentialOnly.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI

struct WithCredentialOnly<Content: View>: View {
  let credential: RedditCredential?
  @ViewBuilder let content: () -> Content
    var body: some View {
      if !((credential?.validationStatus ?? .invalid) == .authorized) {
        VStack(spacing: 20) {
          VStack(spacing: 12) {
            Image(systemName: credential == nil ? "questionmark.key.filled" : "key.slash.fill")
              .fontSize(64, .bold)
              .opacity(0.5)
            VStack(spacing: 4) {
              Text(credential == nil ? "No credential" : "Credential invalid")
                .fontSize(24, .bold)
                .opacity(0.5)
              Text("We can't load this page 😔").fontSize(16, .medium).opacity(0.35)
            }
          }
          Button("Go to credentials settings", systemImage: "gear") {
            Nav.fullTo(.settings, .setting(.credentials))
          }
          .buttonStyle(.actionOutlined)
          .opacity(0.5)
        }
        .compositingGroup()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        content()
      }
    }
}

