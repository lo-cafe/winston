//
//  Winston MD.swift
//  winston
//
//  Created by Ethan Bills on 1/12/24.
//

import SwiftUI
import MarkdownUI

extension Theme {
  /// Winston Markdown theme.
  public static func winstonMarkdown(fontSize: CGFloat, lineSpacing: CGFloat = 0.2, textSelection: Bool = false) -> Theme {
    let theme = Theme()
      .text {
        FontSize(fontSize)
      }
      .paragraph { configuration in
        configuration.label
          .lineSpacing(lineSpacing)
          .fontSize(fontSize)
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
      .heading1 { configuration in
        configuration.label
          .markdownTextStyle {
            FontSize(fontSize * 2)
          }
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
      .heading2 { configuration in
        configuration.label
          .markdownTextStyle {
            FontSize(fontSize * 1.5)
          }
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
      .heading3 { configuration in
        configuration.label
          .markdownTextStyle {
            FontSize(fontSize * 1.25)
          }
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
      .listItem { configuration in
        configuration.label
          .markdownMargin(top: .em(0.3))
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
      .codeBlock { configuration in
        configuration.label
          .markdownTextStyle {
            FontSize(.em(0.85))
						FontFamilyVariant(.monospaced)
          }
          .padding()
          .background(Color(.secondarySystemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .markdownMargin(top: .zero, bottom: .em(0.8))
          .textSelection(WinstonTextSelectability(allowsSelection: textSelection))
      }
		  .blockquote { configuration in
				configuration.label
					.markdownTextStyle {
						FontSize(.em(0.85))
						FontFamilyVariant(.monospaced)
					}
					.padding()
					.background(Color(.secondarySystemBackground))
					.clipShape(RoundedRectangle(cornerRadius: 8))
					.markdownMargin(top: .zero, bottom: .em(0.8))
					.textSelection(WinstonTextSelectability(allowsSelection: textSelection))
			}
			.table { configuration in
				ScrollView (.horizontal) {
						configuration.label
							.fixedSize(horizontal: false, vertical: true)
							.markdownTableBackgroundStyle(
								.alternatingRows(Color(.systemBackground), Color(.secondarySystemBackground))
							)
							.markdownMargin(top: 0, bottom: 16)
					}
					}
					.tableCell { configuration in
						configuration.label
							.markdownTextStyle {
								if configuration.row == 0 {
									FontWeight(.semibold)
								}
								BackgroundColor(nil)
							}
							.fixedSize(horizontal: false, vertical: true)
							.padding(.vertical, 6)
							.padding(.horizontal, 13)
							.relativeLineSpacing(.em(0.25))
					}
    return theme
  }
}

struct WinstonTextSelectability: TextSelectability {
  let allowsSelection: Bool
  
  init(allowsSelection: Bool) {
    self.allowsSelection = allowsSelection
  }
  
  static var allowsSelection: Bool {
    return true
  }
}
