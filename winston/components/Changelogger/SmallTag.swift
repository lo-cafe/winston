//
//  SmallTag.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct SmallTag: View {
  var label: String
  var color: Color
  var body: some View {
    Text(label.uppercased())
      .fontSize(12, .bold, design: .rounded)
      .fontWidth(.compressed)
      .foregroundStyle(.primaryInverted)
      .padding(.horizontal, 6)
      .padding(.vertical, 3)
      .background(Capsule(style: .continuous).fill(color))
      .opacity(0.5)
  }
}
