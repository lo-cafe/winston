//
//  OnboardingOpeningSettings.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding1OpeningSettings: View {
  var prevStep: ()->()
  var nextStep: ()->()
  @Environment(\.openURL) var openURL
  var body: some View {
    VStack(spacing: 16) {
      OnboardingBigStep(step: 1)
      
      Text("Open Reddit API settings in Safari by clicking below's button, then, switch back to Winston.")
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 300)
      
      MasterButton(icon: "safari.fill", label: "Open Reddit API settings", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
        nextStep()
        openURL(URL(string: "https://reddit.com/prefs/apps")!)
      })
        .padding(.top, 32)
    }
    .padding(.horizontal, 16)
    .multilineTextAlignment(.center)
  }
}
