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
        do {
            return try AttributedString(markdown: self) /// convert to AttributedString
        } catch {
            return AttributedString("Error parsing markdown: \(error)")
        }
    }
}
