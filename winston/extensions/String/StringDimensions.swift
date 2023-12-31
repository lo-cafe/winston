//
//  StringDimensions.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import Foundation
import SwiftUI

extension String {
  func height(font: UIFont, withConstrainedWidth width: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
  
    return ceil(boundingBox.height)
  }

  func width(font: UIFont, withConstrainedHeight height: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

    return ceil(boundingBox.width)
  }
}
