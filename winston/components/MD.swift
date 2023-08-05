//
//  MD.swift
//  winston
//
//  Created by Igor Marcossi on 14/07/23.
//

import Foundation
import SwiftUI
import MarkdownUI

struct MD: View {
  var str: String
  var fontSize: CGFloat = 15
  var body: some View {
    Markdown(str.escape)
      .markdownTextStyle(\.text) {
        FontSize(fontSize)
      }
      .markdownBlockStyle(\.paragraph) { configuration in
        configuration.label
//          .allowsHitTesting(false)
      }
      .markdownBlockStyle(\.blockquote) { configuration in
        configuration.label
          .padding()
          .markdownTextStyle {
//            FontCapsVariant(.lowercaseSmallCaps)
            FontWeight(.semibold)
            BackgroundColor(nil)
          }
          .background(RR(8, .secondary.opacity(0.2)))
      }
  }
}
