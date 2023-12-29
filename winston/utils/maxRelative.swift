//
//  maxRelative.swift
//  winston
//
//  Created by Igor Marcossi on 30/11/23.
//

import Foundation

func maxRelative(_ value: Double, maxValue: Double) -> Double {
    if value > maxValue {
        return maxValue
    } else if value < -maxValue {
        return -maxValue
    } else {
        return value
    }
}
