//
//  CredentialStatusMetaView.swift
//  winston
//
//  Created by Igor Marcossi on 08/01/24.
//

import SwiftUI

struct CredentialStatusMetaView: View {
  var status: RedditCredential.CredentialValidationState.Meta
  
  @State private var fakeLabel: String
  
  init(_ status: RedditCredential.CredentialValidationState.Meta) {
    self.status = status
    self._fakeLabel = .init(initialValue: status.label)
  }
  var body: some View {
    HStack(spacing: 3) {
      BetterLottieView(status.lottieIcon, size: 19, initialDelay: 0.315, color: status.color)
      
      Text(fakeLabel)
        .fontSize(16, .semibold)
        .foregroundStyle(status.color)
        .transition(.scaleAndBlur)
        .id("cred-meta-icon-\(fakeLabel)")
    }
    .onChange(of: status.label) { _, new in
      withAnimation(.spring) { fakeLabel = new }
    }
  }
}
