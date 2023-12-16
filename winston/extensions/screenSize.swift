//
//  screenSize.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import Foundation
import UIKit

extension Double {
  static let screenW = UIScreen.main.bounds.size.width
  static let screenH = UIScreen.main.bounds.size.height
}

extension CGFloat {
  static let screenW = UIScreen.main.bounds.size.width
  static let screenH = UIScreen.main.bounds.size.height
}

extension CGSize {
  static let screenSize = CGSize(width: .screenW, height: .screenH)
}
