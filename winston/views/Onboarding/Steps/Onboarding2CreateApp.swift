//
//  OnboardingCreateApp.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding2CreateApp: View {
  var prevStep: ()->()
  var nextStep: ()->()
  @Environment(\.openURL) var openURL
  var body: some View {
    VStack(spacing: 16) {
      OnboardingBigStep(step: 2)
      
      Text("Go back to Safari and create a new \"app\" (it's a name for a kind of API key) by clicking the button on the site that look just like this one:")
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 300)
      
      Image("createAppButton")
        .resizable()
        .scaledToFit()
        .frame(maxWidth: UIScreen.screenWidth * 0.75)
        .mask(RR(12, .black))
      
      Text("Then, come back here!")
      
      HStack {
        MasterButton(icon: "arrowshape.backward.fill", label: "Go back", mode: .soft, color: .primary, colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
        prevStep()
      })
      MasterButton(icon: "checkmark.circle.fill", label: "Done", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
        nextStep()
      })
      }
        .padding(.top, 32)
    }
    .padding(.horizontal, 16)
    .multilineTextAlignment(.center)
  }
}
