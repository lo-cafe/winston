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
  var step: CGFloat = 1
  var body: some View {
    VStack(spacing: 10) {
      HStack {
        Text(label)
        Spacer()
        Text((step == 1 ? Int(value).description : String(format: "%.2f", value)))
          .opacity(0.5)
      }
//      .padding(.vertical, 8)
      HStack {
        Text(Int(range.lowerBound).description)
          .fontSize(15)
        Slider(value: $value, in: range, step: step)
        Text(Int(range.upperBound).description)
          .fontSize(15)
      }
    }
    .padding(.horizontal, 16)
  }
}
