//
//  External to Internal Links.swift
//  winston
//
//  Created by Ethan Bills on 1/10/24.
//

import Foundation

class MarkdownUtil {
  static func replaceURLsWithWinstonAppScheme(_ text: String) -> String {
    var processedText = text
    
    // Replace http:// or https:// in existing markdown links
    processedText = processedText.replacingOccurrences(
      of: "\\[([^\\]]+)\\]\\((https?://)(\\S+)(?:\\))",
      with: "[$1](winstonapp://$3)",
      options: .regularExpression
    )

    // Replace URLs with http:// or https:// (if not already in markdown format)
    processedText = processedText.replacingOccurrences(
      of: "\\b(?<!\\[)(https?://)(\\S+)(?!\\])\\b",
      with: "[$0](winstonapp://$2)",
      options: .regularExpression
    )
    
    // Replace /u/example or u/example
    processedText = processedText.replacingOccurrences(
      of: "(\\s|^)(/?u/\\w+)(\\s|\\b)",
      with: " [$2](winstonapp://$2) ",
      options: [.regularExpression, .caseInsensitive]
    )

    // Replace /r/example or r/example
    processedText = processedText.replacingOccurrences(
      of: "(\\s|^)(/?r/\\w+)(\\s|\\b)",
      with: " [$2](winstonapp://$2) ",
      options: [.regularExpression, .caseInsensitive]
    )
    
    return processedText
  }
}
