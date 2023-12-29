//
//  fromHex.swift
//  winston
//
//  Created by Igor Marcossi on 27/06/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
  convenience init(hex: String, alpha: Double = 1) {
    let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
    let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
    let ui64 = UInt64(hexString, radix: 16)
    let value = ui64 != nil ? Int(ui64!) : 0
    // #RRGGBB
    var components = (
      R: CGFloat((value >> 16) & 0xff) / 255,
      G: CGFloat((value >> 08) & 0xff) / 255,
      B: CGFloat((value >> 00) & 0xff) / 255,
      a: CGFloat(alpha)
    )
    if String(hexString).count == 8 {
      // #RRGGBBAA
      components = (
        R: CGFloat((value >> 24) & 0xff) / 255,
        G: CGFloat((value >> 16) & 0xff) / 255,
        B: CGFloat((value >> 08) & 0xff) / 255,
        a: CGFloat((value >> 00) & 0xff) / 255
      )
    }
    self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
  }
  
  func toHex(alpha: Bool = false) -> String? {
    guard let components = cgColor.components, components.count >= 3 else {
      return nil
    }
    
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)
    
    if components.count >= 4 {
      a = Float(components[3])
    }
    
    if alpha {
      return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    } else {
      return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
  }
}

extension UIColor {
    var alpha: CGFloat {
        var alpha: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
}

extension Color {
  static func hex(_ h: String) -> Color {
    var hex = h
    if h.hasPrefix("#") { hex.removeFirst(1) }
    return Color(UIColor(hex: hex))
  }
  
  var alpha: CGFloat { UIColor(self).alpha }
  
  var hex: String {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return "000000"
    }
    let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
    return String(format: "%06x", rgb)
  }
}
