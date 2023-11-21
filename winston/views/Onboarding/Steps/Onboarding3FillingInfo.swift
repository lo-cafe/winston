//
//  Onboarding3FillingInfo.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding3FillingInfo: View {
  var prevStep: ()->()
  var nextStep: ()->()
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        OnboardingBigStep(step: 3)
        
        Text("Go back to Safari and fill the form like below and click the \"create app\" button.")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        Image("filledForm")
          .resizable()
          .scaledToFit()
          .frame(maxWidth: UIScreen.screenWidth * 0.85)
          .mask(RR(12, Color.black))
        
        Text("Here are the values if you wanna quick copy them:")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        VStack {
          CopiableValue(value: "https://lo.cafe")
          CopiableValue(value: "https://winston.cafe/auth-success")
        }
        
      }
      .padding(.vertical, 64)
      .padding(.bottom, 48)
      .padding(.horizontal, 16)
      .multilineTextAlignment(.center)
    }
    .overlay(
      HStack {
        MasterButton(icon: "arrowshape.backward.fill", label: "Go back", mode: .soft, color: .primary, colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
          prevStep()
        })
        MasterButton(icon: "checkmark.circle.fill", label: "Done", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
          nextStep()
        })
      }
      .padding(.bottom, 36)
      .padding(.horizontal, 16)
      , alignment: .bottom
    )
    .ignoresSafeArea(.all)
  }
}
