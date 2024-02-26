//
//  ReleaseFeature.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct ReleaseFeature: View {
  var icon: String
  var title: String
  var description: String
    var body: some View {
      HStack(alignment: .top, spacing: 8) {
        Image(systemName: icon).fontSize(16, .medium)
          .foregroundStyle(.blue)
        
        VStack(alignment: .center, spacing: 0) {
          Text(title).fontSize(16, .medium)
          Text(title).fontSize(15, .regular).opacity(0.75)
        }
      }
      .padding(.all, 12)
      .background(RR(16, .primary))
    }
}
