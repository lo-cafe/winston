//
//  Comment util.swift
//  winston
//
//  Created by Ethan Bills on 1/11/24.
//

import Foundation
import SwiftUI

/// Utility class for handling comments.
class CommentUtils {
  /// Shared instance of CommentUtils.
  static let shared = CommentUtils()
  
  /// Private initializer to enforce singleton pattern.
  private init() {}
  
  // MARK: - Comment Section Helpers
  
  /// Preference key to track the anchor points of comments.
  struct AnchorsKey: PreferenceKey {
    typealias Value = [String: Anchor<CGPoint>]
    static var defaultValue: Value { [:] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
      value.merge(nextValue()) { $1 }
    }
  }
  
  /// Finds the top comment row based on anchors and geometry proxy.
  func topCommentRow(of anchors: CommentUtils.AnchorsKey.Value, in proxy: GeometryProxy) -> String? {
    var yBest = CGFloat.infinity
    var answer: String?
    for (row, anchor) in anchors {
      let y = proxy[anchor].y
      guard y >= 0, y < yBest else { continue }
      answer = row
      yBest = y
    }
    return answer
  }
}
