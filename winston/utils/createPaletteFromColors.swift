//
//  createPaletteFromColors.swift
//  winston
//
//  Created by daniel on 23/11/23.
//

import Foundation
import SwiftUI

/// Creates a color palette with variations from an array of colors.
/// - Parameters:
///   - colors: An array of colors from which to create the palette.
///   - amount: The number of variations to create for each color (default is 3).
/// - Returns: A palette of colors with variations.
func createPaletteFromColors(colors: [Color], amount: Int = 3, opacity: Double = 1) -> [Color] {
    // Ensure that the amount is within the valid range.
    let validAmount = max(1, amount)
    
    // Create an empty array to store the generated palette.
    var palette: [Color] = []
    
    // Iterate through each color in the input array.
    for color in colors {
        // Generate variations for the current color and add them to the palette.
        palette.append(contentsOf: generateColorVariations(baseColor: color, amount: validAmount, opacity: opacity))
    }
    
    return palette
}

/// Generates color variations for a given base color.
/// - Parameters:
///   - baseColor: The base color for which variations are generated.
///   - amount: The number of variations to create.
/// - Returns: An array of colors with variations.
func generateColorVariations(baseColor: Color, amount: Int, opacity: Double) -> [Color] {
    // Ensure that the amount is within the valid range.
    let validAmount = max(1, amount)
    
    // Convert SwiftUI Color to UIColor to easily manipulate color components.
    let uiBaseColor = UIColor(baseColor)
    
    // Get the HSB (Hue, Saturation, Brightness) components of the base color.
    var hsb = uiBaseColor.hsb()
    
    // Create an empty array to store the generated color variations.
    var variations: [Color] = []
    
    // Generate color variations by adjusting the hue, saturation, and brightness.
    for _ in 0..<validAmount {
        // Adjust the hue, saturation, and brightness randomly.
      hsb.hue = (hsb.hue + CGFloat.random(in: -0.1...0.1))
      hsb.saturation = (hsb.saturation + CGFloat.random(in: -0.1...0.1))
      hsb.brightness = (hsb.brightness + CGFloat.random(in: -0.1...0.1))
        
        // Create a new color with the adjusted HSB components and add it to the variations array.
        let variationColor = Color(UIColor(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: 1.0))
      variations.append(variationColor.opacity(opacity))
    }
    
    return variations
}

// Extension to extract HSB components from a UIColor.
extension UIColor {
    func hsb() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return (h, s, b, a)
    }
}
