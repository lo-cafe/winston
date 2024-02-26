//
//  Changelogger.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct Changelogger: View {
  var body: some View {
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 8) {
        BetterLottieView("newspaper", size: 80, color: Color.changelogYellow)
        VStack(alignment: .center, spacing: 0) {
          Text("What's new?").fontSize(32, .bold, design: .rounded)
          Text("Isn't this app beautiful?").fontSize(16, .regular, design: .rounded).opacity(0.75)
        }
      }
      
    }
  }
}
