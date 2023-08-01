//
//  OnboardingBigStep.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct OnboardingBigStep: View {
  var step: Int
  let size: CGFloat = 80
    var body: some View {
        Text("\(step)")
        .fontSize(40, .bold)
        .frame(width: size, height: size)
        .background(.blue, in: Circle())
        .foregroundColor(.white)
    }
}
