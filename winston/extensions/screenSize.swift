//
//  screenSize.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import Foundation
import UIKit

extension CGSize {
  static let screenSize = CGSize(width: .screenW, height: .screenH)
}

extension Double {
  static let screenW = UIScreen.screenWidth
  static let screenH = UIScreen.screenHeight
}

extension CGFloat {
  static let screenW = UIScreen.screenWidth
  static let screenH = UIScreen.screenHeight
}
