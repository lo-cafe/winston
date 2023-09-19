//
//  DataBlock.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI

struct DataBlock: View {
  var icon: String
  var label: String
  var value: String
  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .fontSize(20, .semibold)
        .foregroundColor(.blue)
      VStack(spacing: 0) {
        Text(label)
          .fontSize(14)
          .opacity(0.75)
        Text(value)
          .fontSize(18, .semibold)
      }
    }
    .padding(.all, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(RR(20, Color.listBG))
  }
}
