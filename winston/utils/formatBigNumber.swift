//
//  formatBigNumber.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation

func formatBigNumber(_ number: Int) -> String {
    if number >= 1_000_000_000 {
        return String(format: "%.1fB", Double(number) / 1_000_000_000)
    } else if number >= 1_000_000 {
        return String(format: "%.1fM", Double(number) / 1_000_000)
    } else if number >= 1_000 {
        return String(format: "%.1fK", Double(number) / 1_000)
    } else {
        return "\(number)"
    }
}
