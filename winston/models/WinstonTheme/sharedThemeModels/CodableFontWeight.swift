//
//  CodableFontWeight.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import Foundation
import SwiftUI


enum CodableFontWeight: Codable, Hashable, CaseIterable, Equatable {
  case light, regular, medium, semibold, bold
  
  var t: Font.Weight {
    switch self {
    case .light:
      return .light
    case .regular:
      return .regular
    case .medium:
      return .medium
    case .semibold:
      return .semibold
    case .bold:
      return .bold
//    case .heavy:
//      return .heavy
//    case .black:
//      return .black
    }
  }
  
  var ut: UIFont.Weight {
    switch self {
    case .light:
      return .light
    case .regular:
      return .regular
    case .medium:
      return .medium
    case .semibold:
      return .semibold
    case .bold:
      return .bold
//    case .heavy:
//      return .heavy
//    case .black:
//      return .black
    }
  }
}
