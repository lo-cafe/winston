//
//  Interpolator.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import Foundation
import SwiftUI

func interpolatorBuilder(_ range1: [CGFloat], value: CGFloat) -> ((_ range2: [CGFloat], _ extrapolate: Bool) -> CGFloat) {
    func interpolate (_ range2: [CGFloat], _ extrapolate: Bool) -> CGFloat {
        
        let min1 = range1[0]
        let max1 = range1[1]
        let min2 = range2[0]
        let max2 = range2[1]
        
        if (extrapolate) {
            // Check if value is outside the range1 limits
            if value < min1 {
                let extrapolation = (value - min1) / (min1 - max1)
                // Decrease interpolation speed when within 25% of extrapolation limits
                let interpolationFactor = max(0, 1 + extrapolation / 4)
                return interpolationFactor * (min2 - max2) + max2
            } else if value > max1 {
                let extrapolation = (value - max1) / (min1 - max1)
                // Decrease interpolation speed when within 25% of extrapolation limits
                let interpolationFactor = max(0, 1 - extrapolation / 4)
                return interpolationFactor * (max2 - min2) + min2
            }
        }
        
        // If value is within range1 limits, just return the interpolated value
        return max(
            min(min2, max2),
            min(
                max(min2, max2),
                (value - min1) * (max2 - min2) / (max1 - min1) + min2
            )
        )
    }
    return interpolate
}
