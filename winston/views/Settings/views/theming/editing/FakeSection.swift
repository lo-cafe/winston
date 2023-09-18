//
//  FakeSection.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct FakeSection<Content: View>: View {
  var title: String
  var footer: String?
  @ViewBuilder var content: () -> Content
  
  init(_ title: String, footer: String? = nil, @ViewBuilder _ content: @escaping () -> Content) {
    self.title = title
    self.footer = footer
    self.content = content
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title.uppercased())
        .fontSize(13)
        .padding(.horizontal, 16)
        .opacity(0.5)
      VStack(alignment: .leading, spacing: 8) {
        content()
      }
      .padding(.vertical, 8)
      .background(RR(10, Color.listBG))
      
      if let footer = footer {
        Text(footer)
          .font(.caption)
          .padding(.horizontal, 16)
          .opacity(0.5)
      }
    }
    .padding(.horizontal, 16)
    .fixedSize(horizontal: false, vertical: true)
  }
}

