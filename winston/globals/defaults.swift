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

struct PostInBox: Codable, Identifiable, Hashable, Defaults.Serializable {
  var id: String
  var fullname: String
  var title: String
  var body: String?
  var subredditIconURL: String?
  var img: String?
  var subredditName: String
  var authorName: String
  var subColor: String?
  var score: Int?
  var commentsCount: Int?
  var createdAt: Double?
  var lastUpdatedAt: Double?
}

extension Defaults.Keys {
  static let redditAPILastTokenRefreshDate = Key<Date?>("redditAPILastTokenRefreshDate", default: nil)
  static let redditAPITokenExpiration = Key<Int?>("redditAPITokenExpiration", default: nil)
  static let subreddits = Key<[ListingChild<SubredditData>]>("subreddits", default: [])
  static let postsInBox = Key<[PostInBox]>("postsInBox-v2", default: [])
  static let preferredSort = Key<SubListingSortOption>("preferredSort", default: .hot)
  static let preferredCommentSort = Key<CommentSortOption>("preferredCommentSort", default: .confidence)
  static let preferenceShowPostsAvatars = Key<Bool>("preferenceShowPostsAvatars", default: true)
  static let preferenceShowPostsCards = Key<Bool>("preferenceShowPostsCards", default: true)
  static let preferenceShowCommentsAvatars = Key<Bool>("preferenceShowCommentsAvatars", default: true)
  static let preferenceShowCommentsCards = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let enableVotesPopover = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let maxPostLinkImageHeightPercentage = Key<Double>("maxPostLinkImageHeightPercentage", default: 100)
  static let replyModalBlurBackground = Key<Bool>("replyModalBlurBackground", default: true)
  static let newPostModalBlurBackground = Key<Bool>("newPostModalBlurBackground", default: true)
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
