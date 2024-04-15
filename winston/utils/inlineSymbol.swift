//
//  inlineSymbol.swift
//  winston
//
//  Created by Igor Marcossi on 29/08/23.
//

import Foundation
import SwiftUI

extension Text {
    public struct InlineSymbol {
        public let name: String
        public let accessibilityLabel: String
        public let color: Color?

        public init(name: String, accessibilityLabel: String, color: Color? = nil) {
            self.name = name
            self.accessibilityLabel = accessibilityLabel
            self.color = color
        }
    }

    public static func withSymbolPrefixes(symbols: [InlineSymbol], text: String) -> Text {
        var strText = Text(text)
        for symbol in symbols.reversed() {
            var symbolText =
                Text(Image(systemName: symbol.name))
                .accessibilityLabel(symbol.accessibilityLabel + ", ")
            
            if let color = symbol.color {
                symbolText = symbolText.foregroundColor(color)
            }
        
            strText = symbolText + Text(" ") + strText
        }
        return strText
    }
}
