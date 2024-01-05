//
//  NiceCredentialSection.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

struct NiceCredentialSection<Content: View>: View {
  var label: String
  var content: () -> Content
  
  init(_ label: String, @ViewBuilder _ content: @escaping () -> Content) {
    self.label = label
    self.content = content
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(label).fontSize(20, .bold).padding(.horizontal, 4)
      content()
    }
  }
}
