//
//  MD.swift
//  winston
//
//  Created by Igor Marcossi on 14/07/23.
//

import Foundation
import SwiftUI
import Markdown

enum MDType {
  case str(String)
  case attr(AttributedString)
  case json(String)
}

struct MD: View {
  var str: String?
  var attributedString: AttributedString
  
  init(_ content: MDType, fontSize: CGFloat = 15) {
    switch content {
    case .attr(let attr):
      self.attributedString = attr
    case .str(let str):
      self.str = str
      self.attributedString = stringToAttr(str, fontSize: fontSize)
    case .json(let json):
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: json.data(using: .utf8)!)) ?? AttributedString()
      self.attributedString = jsonData
    }
  }

  var body: some View {
    Text(attributedString)
  }
}


//struct MD: View {
//  var str: String
//  var fontSize: CGFloat
//  @State private var attributedString: AttributedString?
//
//  var body: some View {
//    Text(attributedString.isNil ? AttributedString(stringLiteral: str) : attributedString!)
//      .opacity(attributedString.isNil ? 0 : 1)
//      .onAppear {
//        Task(priority: .background) {
//          let document = Document(parsing: str)
//          var markdownosaur = Markdownosaur(baseFontSize: fontSize)
//          let attributedString = AttributedString(markdownosaur.attributedString(from: document))
//          await MainActor.run {
//            withAnimation {
//              self.attributedString = attributedString
//            }
//          }
//        }
//      }
//  }
//}
