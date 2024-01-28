//
//  External to Internal Links.swift
//  winston
//
//  Created by Ethan Bills on 1/10/24.
//

import Foundation

class MarkdownUtil {
  static func containsSpoiler(_ text: String) -> Bool {
    return text.contains("&gt;!") && text.contains("!&lt;") ||
    text.contains(">!") && text.contains("!<")
  }
  
  static func formatForMarkdown(_ text: String, showSpoiler: Bool = false) -> String {
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
		
		// Replace &#x200B; and &nbsp; with a space
		processedText = processedText.replacingOccurrences(
			of: "&amp;#x200B;|&amp;nbsp;",
			with: " ",
			options: [.regularExpression, .caseInsensitive]
		)
    
    processedText = processedText.replacingOccurrences(
      of: "&gt;",
      with: ">"
    )
    
    processedText = processedText.replacingOccurrences(
      of: "&lt;",
      with: "<"
    )
    
    processedText = processedText.replacingOccurrences(
      of: "&Hat;",
      with: "^"
    )

    if containsSpoiler(processedText) {
      if showSpoiler {
        processedText = processedText.replacingOccurrences(
          of: ">!",
          with: ""
        )
        
        processedText = processedText.replacingOccurrences(
          of: "!<",
          with: ""
        )
      } else {
        processedText = processedText.replacingOccurrences(
          of: ">!(.*?)!<",
          with: "■",
          options: .regularExpression
        )
      }
      
    }
        
    return processedText
  }
}
