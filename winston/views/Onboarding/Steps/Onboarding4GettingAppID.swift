//
//  Onboarding4GettingAppID.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding4GettingAppID: View {
  var prevStep: ()->()
  var nextStep: ()->()
  @Binding var appID: String
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        OnboardingBigStep(step: 4)
        
        Text("Go back to Safari and copy your new \"app\"'s ID that's probably somewhere like this:")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        Image("appIDLocation")
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .screenW * 0.85)
          .mask(RR(12, Color.black))
        
        Text("Now paste it here:")
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: 300)
        
        TextField("", text: $appID, prompt: Text("Paste here the app ID"))
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.none)
          .fontSize(16, .medium)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(RR(16, Color.black.opacity(0.1)))
        
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
      .padding(.vertical, 64)
      .padding(.horizontal, 16)
      .multilineTextAlignment(.center)
//      .contentShape(Rectangle())
//      .onTapGesture { withAnimation { UIApplication.shared.dismissKeyboard() } }
    }
    .modifier(AdaptsToSoftwareKeyboard())
    .scrollDismissesKeyboard(.immediately)
  }
}
