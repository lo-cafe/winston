//
//  CredentialEditView.swift
//  winston
//
//  Created by Igor Marcossi on 22/11/23.
//

import SwiftUI
import NukeUI

struct CredentialEditView: View {
  var credential: RedditCredential
  @Binding var draftCredential: RedditCredential
  @Binding var navPath: [CredentialEditStack.Mode]
  
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  @Environment(\.dismiss) private var dismiss
  
  var creating: Bool { !draftCredential.isInKeychain() }
    
  var currentStatusInfo: EditCredentialProfile.StatusInfo {
    return switch draftCredential.validationStatus {
    case .authorized: .init(color: .green, lottieIcon: "thumbup", label: "Perfect", description: "This means you can use this account normally.")
    case .maybeValid, .valid: .init(color: .orange, lottieIcon: "warning-appear", label: "Unauthorized", description: "This means you need to allow your credentials to access your account.")
    case .empty, .invalid: .init(color: .red, lottieIcon: "thumbdown", label: "Invalid", description: "This means that you credential info is wrong.")
    }
  }
  
  @ViewBuilder
  func showBtns() -> some View {
    VStack(spacing: creating ? 16 : 14) {
      BigCredBtn(nav: $navPath, img: { Image(.winstonSide).size(56) }, title: !creating ? "Guided replace" : "Guided mode", description: "A guided walkthrough to \(!creating ? "replace this credential by another" : "generate or select a credential").", page: .assistant, recommended: true)
      BigCredBtn(nav: $navPath, img: { Image(systemName: "gear").fontSize(44, .semibold).foregroundStyle(Color.accentColor) }, title: !creating ? "Advanced settings" : "Advanced mode", description: "Manually \(creating ? "enter" : "edit") your credentials and get nerd info.", page: .advanced)
    }
    .frame(maxWidth: .infinity)
  }
  
  var body: some View {
    let anyChanges = credential != draftCredential
    let accentColor = theme.general.accentColor.cs(cs).color()
    
    Group {
      if creating {
        VStack(spacing: 32) {
          VStack(spacing: 16) {
            BetterLottieView("keys", size: 120, color: accentColor)
            
            VStack(spacing: 4) {
              Text("Create Credential").fontSize(32, .bold)
              Text("There are two ways for doing that:")
            }
          }
          
          showBtns()
        }
        .padding(.top, 48)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      } else {
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            
            EditCredentialProfile(pictureURL: draftCredential.profilePicture, username: draftCredential.userName ?? "New credential", statusInfo: currentStatusInfo)
            
            EditCredWhatToDoBanner(draftCredential: $draftCredential)
            
            VStack(alignment: .leading, spacing: 10) {
              Text("What else can you do").fontSize(21, .semibold)
              showBtns()
            }
          }
          .padding(.all, 16)
        }
      }
    }
    .themedListBG(theme.lists.bg)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) { Button("Cancel", role: .destructive) { dismiss() } }
      ToolbarItem(placement: .topBarTrailing) { Button("Save") { draftCredential.save(); dismiss() } .disabled(!anyChanges) }
    }
    .multilineTextAlignment(.center)
    .navigationTitle(creating ? "New credential" : "Edit credential")
    .navigationBarTitleDisplayMode(.inline)
  }
}

