//
//  Onboarding6Auth.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding6Auth: View {
  var prevStep: ()->()
  var nextStep: ()->()
  var appSecret: String
  var appID: String
  @State private var loading = false
  @State private var error = false
  @EnvironmentObject private var redditAPI: RedditAPI
  @Environment(\.openURL) private var openURL
  var body: some View {
      VStack(spacing: 16) {
        OnboardingBigStep(step: 6)
        
        Text("Last step, now you need to allow the new API key to access your account (yes, it's confusing).")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        Text("For that, just click below's button, scroll down the page and click \"Accept\".")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        HStack {
          MasterButton(icon: "arrowshape.backward.fill", label: "Go back", mode: .soft, color: .primary, colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
            prevStep()
          })
          MasterButton(icon: "flag.checkered", label: "Authorize API key", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
            withAnimation {
              redditAPI.loggedUser.apiAppID = appID.trimmingCharacters(in: .whitespaces)
              redditAPI.loggedUser.apiAppSecret = appSecret.trimmingCharacters(in: .whitespaces)
              loading = true
            }
            openURL(redditAPI.getAuthorizationCodeURL(appID))
          })
        }
        .padding(.top, 32)
        
        if error {
          VStack {
            Image(systemName: "xmark.seal.fill")
            Text("Something went wrong, you probably didn't enter the correct information in the previous steps.")
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: 300)
          }
          .foregroundColor(.red)
        }
      }
      .padding(.horizontal, 16)
      .multilineTextAlignment(.center)
      .blur(radius: loading ? 40 : 0)
      .opacity(loading ? 0.25 : 1)
      .allowsHitTesting(!loading)
      .overlay(
        !loading
        ? nil
        : ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      )
      .onOpenURL { url in
        redditAPI.monitorAuthCallback(url) { success in
          if success {
            nextStep()
          } else {
            withAnimation {
              loading = false
              error = true
            }
          }
        }
      }
  }
}
