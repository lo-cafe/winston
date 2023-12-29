//
//  Onboarding7Ending.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct Onboarding7Ending: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "checkmark")
        .fontSize(40, .bold)
        .frame(width: 80, height: 80)
        .background(.green, in: Circle())
        .foregroundColor(.white)
      
      Text("It worked!")
        .fontSize(32, .bold)
        .foregroundColor(.green)
      Text("Winston is ready to be used!")
        .opacity(0.75)
      
      
      MasterButton(icon: "party.popper.fill", label: "Start using Winston!", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
        withAnimation {
          dismiss()
        }
      })
    }
    .padding(.horizontal, 16)
    .multilineTextAlignment(.center)
  }
}
