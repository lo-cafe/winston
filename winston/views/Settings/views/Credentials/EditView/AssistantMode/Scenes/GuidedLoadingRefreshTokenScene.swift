//
//  GuidedLoadingRefreshTokenScene.swift
//  winston
//
//  Created by Igor Marcossi on 07/01/24.
//

import SwiftUI

struct GuidedLoadingRefreshTokenScene: View {
  @Environment(\.colorScheme) private var cs
  var body: some View {
    VStack(spacing: 16) {
      BetterLottieView("spinner", size: 56, color: cs == .dark ? .white : .black).opacity(0.85)
      VStack(spacing: 8) {
        Text("Loggin in...").fontSize(32, .bold)
        Text("Almost there, 1 sec!")
      }
    }
    .multilineTextAlignment(.center)
  }
}
