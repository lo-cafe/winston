//
//  PostLinkTitle.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

struct PostLinkTitle: View, Equatable {
  static func == (lhs: PostLinkTitle, rhs: PostLinkTitle) -> Bool {
    lhs.label == rhs.label && lhs.size == rhs.size
  }
  var attrString: NSAttributedString? = nil
  var label: String
  var theme: ThemeText
  var size: CGSize
  
  var body: some View {
    if let attrString = attrString {
      Prepend(attrString: attrString, title: label, fontSize: theme.size, fontWeight: theme.weight.ut, color: theme.color.uiColor(), size: size)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
    }
//          Text(label)
//            .fontSize(theme.size, theme.weight.t)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(maxWidth: .infinity, alignment: .topLeading)
  }
}
