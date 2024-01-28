//
//  StringToMD.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import Foundation
import SwiftUI

extension String {
  func md() -> AttributedString {
    //    if let htmlDecodedString = self.escape() {
    let htmlDecodedString = self
    do {
      let asq = try AttributedString(markdown: htmlDecodedString, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
      return asq
    } catch {}
    
    let lines = htmlDecodedString.split(whereSeparator: \.isNewline)
    var attributedString = AttributedString("")
    
    lines.forEach { line in
      var newLineStr = String(line)
      if newLineStr.hasPrefix("#") {
        newLineStr.removeFirst()
        do {
          var newLineAttrStr = try AttributedString(markdown: newLineStr)
          newLineAttrStr.foregroundColor = .orange
          newLineAttrStr.backgroundColor = .white
          attributedString.append(newLineAttrStr)
        } catch { }
      } else {
        do {
          let newLineAttrStr = try AttributedString(markdown: newLineStr)
          attributedString.append(newLineAttrStr)
        } catch { }
      }
    }
    
    return attributedString
  }
}

//extension String {
//    var markdownToAttributedString: AttributedString {
//        var as = AttributedString(self)
//
//        let patterns = [
//            "\\*\\*(.+?)\\*\\*": UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
//            "\\*(.+?)\\*": UIFont.italicSystemFont(ofSize: UIFont.systemFontSize),
//            "\\#\\s(.+?)": UIFont.systemFont(ofSize: 24.0, weight: .bold),
//            "\\#\\#\\s(.+?)": UIFont.systemFont(ofSize: 18.0, weight: .bold),
//            "\\#\\#\\#\\s(.+?)": UIFont.systemFont(ofSize: 14.0, weight: .bold),
//            "\\#\\#\\#\\#\\s(.+?)": UIFont.systemFont(ofSize: 10.0, weight: .bold),
//            "\\>(.+?)\\n": UIFont.systemFont(ofSize: UIFont.systemFontSize)
//        ]
//
//        patterns.forEach { pattern, font in
//            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
//            let matches = regex.matches(in: as.string, options: [], range: NSRange(location: 0, length: as.string.utf16.count))
//
//            for match in matches {
//                let matchRange = match.range(at: 1)
//                if let range = Range(matchRange, in: as.string) {
//                    as[range].font = font
//                }
//            }
//        }
//
//        // Match Links
//        do {
//            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//            let matches = detector.matches(in: as.string, options: [], range: NSRange(location: 0, length: as.string.utf16.count))
//            for match in matches {
//                if let urlRange = Range(match.range, in: as.string) {
//                    as[urlRange].link = URL(string: as.string[urlRange])
//                }
//            }
//        } catch {
//            print("Failed to match links: \(error)")
//        }
//
//        return as
//    }
//}


extension String {
  var niceMD: AttributedString {
    let patterns = [
      "\\*\\*(.+?)\\*\\*": [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)],
      "\\*(.+?)\\*": [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)],
      "\\[(.*?)\\]\\((.*?)\\)": [NSAttributedString.Key.link: URL(string: "$2") as Any],
      "\\>(.+?)\\n": [NSAttributedString.Key.backgroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)],
      "\\#\\s(.+?)\\n": [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)],
      "\\#\\#\\s(.+?)\\n": [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)],
      "\\#\\#\\#\\s(.+?)\\n": [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)],
      "\\#\\#\\#\\#\\s(.+?)\\n": [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10) ],
      "\\s{2,}(\\n)": [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10) ],
    ]
    
    var input = [String]()
    self.enumerateLines { line, _ in
      input.append(line)
    }
    
    let output = NSMutableAttributedString()
    
    input.forEach { line in
      let formattedLine = NSMutableAttributedString(string: line)
      
      patterns.forEach { pattern, attributes in
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: line, range: NSRange(formattedLine.string.startIndex..., in: formattedLine.string))
        
        for match in matches {
          let range = match.range(at: 1)
          let string = (formattedLine.string as NSString).substring(with: range)
          let attributedString = NSAttributedString(string: string, attributes: attributes)
          formattedLine.replaceCharacters(in: range, with: attributedString)
        }
      }
      
      output.append(formattedLine)
      output.append(NSAttributedString(string: "\n"))
    }
    
    return AttributedString(output)
  }
}


