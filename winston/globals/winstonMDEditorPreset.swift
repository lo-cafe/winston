//
//  winstonMDEditorTheme.swift
//  winston
//
//  Created by Igor Marcossi on 25/07/23.
//

import Foundation
import SwiftUI
import HighlightedTextEditor

private let defaultEditorFont = UIFont.preferredFont(forTextStyle: .body)
private let defaultEditorTextColor = UIColor.label

private let inlineCodeRegex = try! NSRegularExpression(pattern: "`[^`]*`", options: [])
private let codeBlockRegex = try! NSRegularExpression(
  pattern: "(`){3}((?!\\1).)+\\1{3}",
  options: [.dotMatchesLineSeparators]
)
//private let headingRegex = try! NSRegularExpression(pattern: "(?<=(^#{1,6})[^\\S\\r\\n]).+$", options: [.anchorsMatchLines])
private let headingRegex = try! NSRegularExpression(pattern: "^#{1,6}[^\\S\\r\\n].+$", options: [.anchorsMatchLines])
private let linkOrImageRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
private let linkOrImageTagRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\[(.*?)\\]", options: [])
private let boldRegex = try! NSRegularExpression(pattern: "((\\*|_){2})((?!\\1).)+\\1", options: [])
private let underscoreEmphasisRegex = try! NSRegularExpression(pattern: "(?<!_)_[^_]+_(?!\\*)", options: [])
private let asteriskEmphasisRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)((?!\\1).)+\\1(?!\\*)", options: [])
private let boldEmphasisAsteriskRegex = try! NSRegularExpression(pattern: "(\\*){3}((?!\\1).)+\\1{3}", options: [])
private let blockquoteRegex = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
private let horizontalRuleRegex = try! NSRegularExpression(pattern: "\n\n(-{3}|\\*{3})\n", options: [])
private let unorderedListRegex = try! NSRegularExpression(pattern: "^(\\-|\\*)\\s", options: [.anchorsMatchLines])
private let orderedListRegex = try! NSRegularExpression(pattern: "^\\d*\\.\\s", options: [.anchorsMatchLines])
private let buttonRegex = try! NSRegularExpression(pattern: "<\\s*button[^>]*>(.*?)<\\s*/\\s*button>", options: [])
private let strikethroughRegex = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [])
private let tagRegex = try! NSRegularExpression(pattern: "^\\[([^\\[\\]]*)\\]:", options: [.anchorsMatchLines])
private let footnoteRegex = try! NSRegularExpression(pattern: "\\[\\^(.*?)\\]", options: [])
private let asteriskSymbolsRegex = try! NSRegularExpression(pattern: "(\\*){1,3}(?=\\w)|(?<=\\w)(\\*){1,3}", options: [])
private let underscoresSymbolsRegex = try! NSRegularExpression(pattern: "(\\_){1,2}(?=\\w)|(?<=\\w)(\\_){1,2}", options: [])
private let hashtagsSymbolsRegex = try! NSRegularExpression(pattern: "(^#{1,6}(?=[^\\S\\r\\n].+))", options: [.anchorsMatchLines])
// courtesy https://www.regular-expressions.info/examples.html
private let htmlRegex = try! NSRegularExpression(
  pattern: "<([A-Z][A-Z0-9]*)\\b[^>]*>(.*?)</\\1>",
  options: [.dotMatchesLineSeparators, .caseInsensitive]
)

let codeFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .thin)
let headingTraits: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitExpanded]
let boldTraits: UIFontDescriptor.SymbolicTraits = [.traitBold]
let emphasisTraits: UIFontDescriptor.SymbolicTraits = [.traitItalic]
let boldEmphasisTraits: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitItalic]
let secondaryBackground = UIColor.secondarySystemBackground
let lighterColor = UIColor.lightGray
let textColor = UIColor.label

private let maxHeadingLevel = 6

var winstonMDEditorPreset: [HighlightRule] {
  [
    HighlightRule(pattern: inlineCodeRegex, formattingRule: TextFormattingRule(key: .font, value: codeFont)),
    HighlightRule(pattern: codeBlockRegex, formattingRule: TextFormattingRule(key: .font, value: codeFont)),
    HighlightRule(pattern: headingRegex, formattingRules: [
      TextFormattingRule(fontTraits: headingTraits),
      TextFormattingRule(key: .kern, value: 0.5),
      TextFormattingRule(key: .font, calculateValue: { content, _ in
        let uncappedLevel = content.prefix(while: { char in char == "#" }).count
        let level = Swift.min(maxHeadingLevel, uncappedLevel)
//        let fontSize = CGFloat(maxHeadingLevel - level) * 2.5 + defaultEditorFont.pointSize
        let fontSize = CGFloat(23 - level)
        return SystemFontAlias(descriptor: defaultEditorFont.fontDescriptor, size: fontSize) as Any
      })
    ]),
    HighlightRule(
      pattern: linkOrImageRegex,
      formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
    ),
    HighlightRule(
      pattern: linkOrImageTagRegex,
      formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
    ),
    HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(fontTraits: boldTraits)),
    HighlightRule(
      pattern: asteriskEmphasisRegex,
      formattingRule: TextFormattingRule(fontTraits: emphasisTraits)
    ),
    HighlightRule(
      pattern: underscoreEmphasisRegex,
      formattingRule: TextFormattingRule(fontTraits: emphasisTraits)
    ),
    HighlightRule(
      pattern: boldEmphasisAsteriskRegex,
      formattingRule: TextFormattingRule(fontTraits: boldEmphasisTraits)
    ),
    HighlightRule(
      pattern: blockquoteRegex,
      formattingRule: TextFormattingRule(key: .backgroundColor, value: secondaryBackground)
    ),
    HighlightRule(
      pattern: horizontalRuleRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: unorderedListRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: orderedListRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: asteriskSymbolsRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: underscoresSymbolsRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: hashtagsSymbolsRegex,
      formattingRules: [
        TextFormattingRule(key: .foregroundColor, value: lighterColor),
        TextFormattingRule(key: .font, calculateValue: { content, _ in
          return SystemFontAlias(descriptor: defaultEditorFont.fontDescriptor, size: 15) as Any
        })
      ]
    ),
    HighlightRule(
      pattern: buttonRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(pattern: strikethroughRegex, formattingRules: [
      TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
      TextFormattingRule(key: .strikethroughColor, value: textColor)
    ]),
    HighlightRule(
      pattern: tagRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(
      pattern: footnoteRegex,
      formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ),
    HighlightRule(pattern: htmlRegex, formattingRules: [
      TextFormattingRule(key: .font, value: codeFont),
      TextFormattingRule(key: .foregroundColor, value: lighterColor)
    ])
  ]
}
