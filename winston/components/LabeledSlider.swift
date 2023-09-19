//
//  LabeledSlider.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct LabeledSlider: View {
  var label: String
  @Binding var value: CGFloat
  var range: ClosedRange<CGFloat>
  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Text(label)
        Spacer()
        Text(Int(value).description)
          .opacity(0.5)
      }
      .padding(.vertical, 8)
      HStack {
        Text(Int(range.lowerBound).description)
          .fontSize(15)
        Slider(value: $value, in: range, step: 1)
        Text(Int(range.upperBound).description)
          .fontSize(15)
      }
    }
    .padding(.horizontal, 16)
  }
}
