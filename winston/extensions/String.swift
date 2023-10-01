//
//  String.swift
//  winston
//
//  Created by Igor Marcossi on 01/10/23.
//

import Foundation

extension String {
  static func +(lhs: String, rhs: String?) -> String {
    return "\(lhs)\(rhs ?? "")"
  }
}
