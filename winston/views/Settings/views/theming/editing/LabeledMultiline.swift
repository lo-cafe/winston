//
//  LabeledMultiline.swift
//  winston
//
//  Created by Igor Marcossi on 16/09/23.
//

import SwiftUI

struct LabeledMultiline<Content: View>: View {
  var label: String
  @ViewBuilder var content: () -> Content
  
  init(_ label: String, @ViewBuilder _ content: @escaping () -> Content) {
    self.label = label
    self.content = content
  }
    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text(label)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
        content()
      }
    }
}
