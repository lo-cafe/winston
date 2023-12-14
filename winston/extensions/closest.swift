//
//  closest.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import Foundation

extension Array where Element == CGFloat {
    func closest(to value: CGFloat) -> Int? {
        guard !isEmpty else { return nil }
        var closest = self[0]
        var index = 0
        for (i,element) in enumerated() {
            if abs(element - value) < abs(closest - value) {
                closest = element
                index = i
            }
        }
        return index
    }
}
