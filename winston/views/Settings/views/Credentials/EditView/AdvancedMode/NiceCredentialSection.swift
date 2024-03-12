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
  var footer: String?
  
  init(_ label: String, footer: String? = nil, @ViewBuilder _ content: @escaping () -> Content) {
    self.label = label
    self.content = content
    self.footer = footer
  }
  var body: some View {
    NiceCredentialSectionExtra(label, footer: footer) {
      content()
    } trailing: {
      EmptyView()
    }
  }
}


struct NiceCredentialSectionExtra<C: View, TC: View>: View {
  var label: String
  var content: () -> C
  var trailingContent: () -> TC
  var footer: String?
  
  init(_ label: String, footer: String? = nil, @ViewBuilder _ content: @escaping () -> C, @ViewBuilder trailing: @escaping () -> TC) {
    self.label = label
    self.content = content
    self.trailingContent = trailing
    self.footer = footer
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Text(label).fontSize(20, .semibold)
          Spacer()
          trailingContent()
        }
        .padding(.horizontal, 4)
        content()
      }
      if let footer {
        Text(footer).fontSize(13).opacity(0.5).padding(.horizontal, 16)
      }
    }
  }
}
