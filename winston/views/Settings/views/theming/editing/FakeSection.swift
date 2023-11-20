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
  @State private var collapse = false
  
  init(_ title: String, footer: String? = nil, @ViewBuilder _ content: @escaping () -> Content) {
    self.title = title
    self.footer = footer
    self.content = content
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(title.uppercased())
          .fontSize(13)
          .opacity(0.5)
        Spacer()
        Image(systemName: "chevron.down")
          .fontSize(13, .semibold)
          .foregroundStyle(Color.accentColor)
          .rotationEffect(Angle(degrees: collapse ? -90 : 0))
          .onTapGesture { withAnimation(.default) { collapse.toggle() }}
      }
        .padding(.horizontal, 16)
      
      if !collapse {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.vertical, 8)
        .themedListRowBG()
        .mask(RR(10, .black))
        
        if let footer = footer {
          Text(footer)
            .fontSize(13)
            .padding(.horizontal, 16)
            .opacity(0.5)
        }
      }
    }
    .padding(.horizontal, 16)
    .clipped()
    .fixedSize(horizontal: false, vertical: true)
  }
}

