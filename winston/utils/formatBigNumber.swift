//
//  formatBigNumber.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation

func formatBigNumber(_ number: Int) -> String {
    var formattedNumber = ""
    let numberInBillion = Double(number) / 1_000_000_000
    let numberInMillion = Double(number) / 1_000_000
    let numberInThousands = Double(number) / 1_000

    if numberInBillion >= 1.0 {
        formattedNumber = String(format: "%.1fB", numberInBillion)
    } else if numberInMillion >= 1.0 {
        formattedNumber = String(format: "%.1fM", numberInMillion)
    } else if numberInThousands >= 1.0 {
        formattedNumber = String(format: "%.1fK", numberInThousands)
    } else {
        formattedNumber = "\(number)"
    }

    return formattedNumber
}
