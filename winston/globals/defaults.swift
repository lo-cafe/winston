//
//  defaults.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import Foundation
import Defaults
import UIKit
import SwiftUI

extension Defaults.Keys {
  static let redditAPILastTokenRefreshDate = Key<Date?>("redditAPILastTokenRefreshDate", default: nil)
  static let redditAPITokenExpiration = Key<Int?>("redditAPITokenExpiration", default: nil)
  static let subreddits = Key<[ListingChild<SubredditData>]>("subreddits", default: [])
  static let preferredSort = Key<SubListingSortOption>("preferredSort", default: .hot)
  static let preferredCommentSort = Key<CommentSortOption>("preferredCommentSort", default: .confidence)
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

let spring = Animation.interpolatingSpring(stiffness: 300, damping: 20, initialVelocity: 0)
