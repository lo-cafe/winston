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
  var size: CGSize
  var tags: [PrependTag] = []
  init(label: String, theme: ThemeText, cs: ColorScheme, size: CGSize, nsfw: Bool = false, flair: String? = nil) {
    self.label = label
    self.theme = theme
    self.cs = cs
    self.size = size
    
    if nsfw { tags.append(.init(label: "NSFW", bgColor: .red.opacity(0.25))) }
    if let flair = flair { tags.append(.init(label: flair, bgColor: .primary.opacity(0.2))) }
  }
    var body: some View {
      Prepend(title: label, fontSize: theme.size, fontWeight: theme.weight.ut, color: theme.color.cs(cs).color(), tags: tags, size: size)
//      Text(label)
//        .fontSize(theme.size, theme.weight.t)
//        .fixedSize(horizontal: false, vertical: true)
//        .frame(maxWidth: .infinity, alignment: .topLeading)
//        .id("post-link-title")
    }
}
