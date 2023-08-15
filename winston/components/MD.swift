//
//  MD.swift
//  winston
//
//  Created by Igor Marcossi on 14/07/23.
//

import Foundation
import SwiftUI
import Markdown

struct MD: View {
  var attributedString: NSAttributedString
  var fontSize: CGFloat = 15
  
  init(str: String, fontSize: CGFloat = 15) {
    let document = Document(parsing: str)
    var markdownosaur = Markdownosaur()
    let attributedString = markdownosaur.attributedString(from: document)
    self.attributedString = attributedString
    self.fontSize = fontSize
  }
  
  var body: some View {
    Text(AttributedString(attributedString))
//      .markdownTextStyle(\.text) {
//        FontSize(fontSize)
//      }
//      .markdownBlockStyle(\.paragraph) { configuration in
//        configuration.label
////          .allowsHitTesting(false)
//      }
//      .markdownBlockStyle(\.blockquote) { configuration in
//        configuration.label
//          .padding()
//          .markdownTextStyle {
////            FontCapsVariant(.lowercaseSmallCaps)
//            FontWeight(.semibold)
//            BackgroundColor(nil)
//          }
//          .background(RR(8, .secondary.opacity(0.2)))
//      }
  }
}
