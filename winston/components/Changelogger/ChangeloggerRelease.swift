//
//  ChangeloggerRelease.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct ChangeloggerRelease: View {
  var body: some View {
    HStack(alignment: .top, spacing: 4) {
      VStack(alignment: .center, spacing: -12) {
        BetterLottieView("star", size: 44, color: .yellow)
      }
      VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading, spacing: 0) {
          VStack(alignment: .leading, spacing: 6) {
            Text("v1.5.6").fontSize(24, .bold, design: .rounded)
            SmallTag(label: "BETA", color: .changelogYellow)
          }
          .padding(.top, 7)
          .padding(.bottom, 6)
          
          Text("This update includes new features and bug fixes.").fontSize(15, .regular, design: .rounded).opacity(0.75)
        }
        
        Text("Features").fontSize(24, .semibold, design: .rounded)
        
        ReleaseFeature(icon: "", title: "", description: "")
      }
    }
    .padding(.all, 16)
  }
}
