//
//  stringToAttr.swift
//  winston
//
//  Created by Igor Marcossi on 03/09/23.
//

import SwiftUI
import Markdown

func stringToAttr(_ str: String, fontSize: CGFloat = 15) -> AttributedString {
  let document = Document(parsing: str)
  var markdownosaur = Markdownosaur(baseFontSize: fontSize)
  let attributedString = markdownosaur.attributedString(from: document)
  return AttributedString(attributedString)
}
