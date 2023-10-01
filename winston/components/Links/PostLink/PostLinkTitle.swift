//
//  PostLinkTitle.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

struct PostLinkTitle: View {
  var label: String
  var theme: ThemeText
  var cs: ColorScheme
    var body: some View {
      Text(label)
        .fontSize(theme.size, theme.weight.t)
        .foregroundColor(theme.color.cs(cs).color())
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .topLeading)
//        .id("post-link-title")
    }
}
