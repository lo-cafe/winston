//
//  modifyColor.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import Foundation
import SwiftUI

extension UIColor {
    var brightness: Double {
      var r: CGFloat = 0
      var g: CGFloat = 0
      var b: CGFloat = 0
      var a: CGFloat = 0
      self.getRed(&r, green: &g, blue: &b, alpha: &a)
      return Double(0.299 * r + 0.587 * g + 0.114 * b)
    }
  
  private func makeColor(componentDelta: CGFloat) -> UIColor {
      var red: CGFloat = 0
      var blue: CGFloat = 0
      var green: CGFloat = 0
      var alpha: CGFloat = 0
      
      // Extract r,g,b,a components from the
      // current UIColor
      getRed(
          &red,
          green: &green,
          blue: &blue,
          alpha: &alpha
      )
      
      // Create a new UIColor modifying each component
      // by componentDelta, making the new UIColor either
      // lighter or darker.
      return UIColor(
          red: add(componentDelta, toComponent: red),
          green: add(componentDelta, toComponent: green),
          blue: add(componentDelta, toComponent: blue),
          alpha: alpha
      )
  }
  
  // Add value to component ensuring the result is
  // between 0 and 1
  private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
      return max(0, min(1, toComponent + value))
  }
  
  func lighter(by componentDelta: CGFloat = 0.1) -> UIColor {
      return makeColor(componentDelta: componentDelta)
  }
  
  func darker(by componentDelta: CGFloat = 0.1) -> UIColor {
      return makeColor(componentDelta: -1*componentDelta)
  }
}

extension Color {
  func darken(_ amount: CGFloat) -> Color { return Color(UIColor(self).darker(by: amount)) }
  func lighten(_ amount: CGFloat) -> Color { return Color(UIColor(self).lighter(by: amount)) }
  
  func brightness() -> Double {
    return UIColor(self).brightness
  }
}
