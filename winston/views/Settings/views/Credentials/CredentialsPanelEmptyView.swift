//
//  CredentialsPanelEmptyView.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import SwiftUI
import Defaults

struct CredentialsPanelEmptyView: View {
  var body: some View {
    VStack(spacing: 20) {
      VStack(spacing: 16) {
        Image(.emptyCredential)
          .resizable()
          .frame(136)
          .clipShape(Circle())
        VStack(spacing: 4) {
          Text("Omg, no credentials!")
            .fontSize(24, .bold)
          Text("Well, you got 2 options:").fontSize(16, .medium).opacity(0.75)
        }
      }
      
      VStack(spacing: 16) {
        Button("Add a new credential", systemImage: "person.fill.badge.plus") {
          Nav.present(.editingCredential(.init()))
        }
        .buttonStyle(.action)
        
        Button(action: {
          Defaults[.GeneralDefSettings].onboardingState = .active
          Nav.present(.onboarding)
        }, label: {
          Label {
            Text("Restart welcome tutorial")
          } icon: {
            Image(.winstonFlat)
              .asFontSize(17)
          }
        })
        .buttonStyle(.actionSecondary)
      }
      
    }
    .compositingGroup()
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
