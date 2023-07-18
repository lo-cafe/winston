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
  var lineLimit: Int?
  var body: some View {
    Markdown(str.stringByDecodingHTMLEntities)
      .if(lineLimit != nil) { view in
          view.lineLimit(lineLimit!)
      }
      .markdownTextStyle(\.text) {
        FontSize(15)
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
