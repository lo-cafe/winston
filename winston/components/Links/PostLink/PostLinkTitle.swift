//
//  PostLinkTitle.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

struct PostLinkTitle: View, Equatable {
  static func == (lhs: PostLinkTitle, rhs: PostLinkTitle) -> Bool {
    lhs.label == rhs.label && lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.size == rhs.size
  }
  var attrString: NSAttributedString?
  var label: String
  var theme: ThemeText
  var cs: ColorScheme
  var size: CGSize
  var tags: [PrependTag] = []
  
  init(attrString: NSAttributedString? = nil, label: String, theme: ThemeText, cs: ColorScheme, size: CGSize, nsfw: Bool = false, flair: String? = nil) {
    self.label = label
    self.theme = theme
    self.cs = cs
    self.size = size
    self.attrString = attrString
    
    //    var newTags: [PrependTag] = []
    //    
    //    if nsfw { newTags.append(.init(label: "NSFW", bgColor: .red.opacity(0.25))) }
    //    if let flair = flair { newTags.append(.init(label: flair, bgColor: .primary.opacity(0.2))) }
    //    self.tags = newTags
    //    self.tags = []
    //    self.attrString = NSAttributedString(string: label)
    //    let newAttrString = attrString ?? buildTitleAttr(title: label, tags: tags, fontSize: theme.size, fontWeight: theme.weight.ut, color: theme.color.cs(cs).color(), size: size)
    //    self.attrString = newAttrString
    
  }
  var body: some View {
    if let attrString = attrString {
      //        Text(attrString)
      Prepend(attrString: attrString, title: label, fontSize: theme.size, fontWeight: theme.weight.ut, color: theme.color.cs(cs).color(), tags: tags, size: size)
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
