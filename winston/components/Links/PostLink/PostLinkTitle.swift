//
//  PostLinkTitle.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

struct PostLinkTitle: View, Equatable {
  static func == (lhs: PostLinkTitle, rhs: PostLinkTitle) -> Bool {
    lhs.label == rhs.label && lhs.theme == rhs.theme && lhs.size == rhs.size && (lhs.attrString?.isEqual(to: rhs.attrString ?? NSAttributedString()) ?? false)
  }
  var attrString: NSAttributedString?
  var label: String
  var theme: ThemeText
  var size: CGSize
  var tags: [PrependTag] = []
  
  init(attrString: NSAttributedString? = nil, label: String, theme: ThemeText, size: CGSize, nsfw: Bool = false, flair: String? = nil) {
    self.label = label
    self.theme = theme
    self.size = size
    self.attrString = attrString
  }
  var body: some View {
    if let attrString = attrString {
      Prepend(attrString: attrString, title: label, fontSize: theme.size, fontWeight: theme.weight.ut, color: theme.color.uiColor(), tags: tags, size: size)
        .equatable()
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
    }
//          Text(label)
//            .fontSize(theme.size, theme.weight.t)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(maxWidth: .infinity, alignment: .topLeading)
  }
}
