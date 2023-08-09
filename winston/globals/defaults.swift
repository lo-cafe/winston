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
  static let blurPostLinkNSFW = Key<Bool>("blurPostLinkNSFW", default: true)
  static let blurPostNSFW = Key<Bool>("blurPostNSFW", default: false)
  static let preferredCommentSort = Key<CommentSortOption>("preferredCommentSort", default: .confidence)
  
//  static let postLinksOuterHPadding = Key<CGFloat>("postLinksOuterHPadding", default: 0)
//  static let postLinksOuterVPadding = Key<CGFloat>("postLinksOuterVPadding", default: 8)
  static let postLinksInnerHPadding = Key<CGFloat>("postLinksInnerHPadding", default: 8)
  static let postLinksInnerVPadding = Key<CGFloat>("postLinksInnerVPadding", default: 14)
  
  static let cardedPostLinksOuterHPadding = Key<CGFloat>("cardedPostLinksOuterHPadding", default: 8)
  static let cardedPostLinksOuterVPadding = Key<CGFloat>("cardedPostLinksOuterVPadding", default: 8)
  static let cardedPostLinksInnerHPadding = Key<CGFloat>("cardedPostLinksInnerHPadding", default: 16)
  static let cardedPostLinksInnerVPadding = Key<CGFloat>("cardedPostLinksInnerVPadding", default: 14)
  
  static let commentsInnerHPadding = Key<CGFloat>("commentsInnerHPadding", default: 8)
//  static let commentsInnerVPadding = Key<CGFloat>("commentsInnerVPadding", default: 0)
  
  static let cardedCommentsOuterHPadding = Key<CGFloat>("cardedCommentsOuterHPadding", default: 8)
//  static let cardedCommentsOuterVPadding = Key<CGFloat>("cardedCommentsOuterVPadding", default: 0)
  static let cardedCommentsInnerHPadding = Key<CGFloat>("cardedCommentsInnerHPadding", default: 13)
//  static let cardedCommentsInnerVPadding = Key<CGFloat>("cardedCommentsInnerVPadding", default: 0)
  
  static let preferenceShowPostsAvatars = Key<Bool>("preferenceShowPostsAvatars", default: true)
  static let preferenceShowPostsCards = Key<Bool>("preferenceShowPostsCards", default: true)
  static let preferenceShowCommentsAvatars = Key<Bool>("preferenceShowCommentsAvatars", default: true)
  static let preferenceShowCommentsCards = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let enableVotesPopover = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let maxPostLinkImageHeightPercentage = Key<Double>("maxPostLinkImageHeightPercentage", default: 100)
  static let replyModalBlurBackground = Key<Bool>("replyModalBlurBackground", default: true)
  static let newPostModalBlurBackground = Key<Bool>("newPostModalBlurBackground", default: true)
  static let showUsernameInTabBar =
    Key<Bool>("showUsernameInTabBar", default: true)
  static let openYoutubeApp = Key<Bool>("openYoutubeApp", default: true)
  static let showHomeFeed = Key<Bool>("showHomeFeed", default: true)
  static let showPopularFeed = Key<Bool>("showPopularFeed", default: true)
  static let showAllFeed = Key<Bool>("showAllFeed", default: true)
  static let showSavedFeed = Key<Bool>("showSavedFeed", default: true)
  static let redditAPIUserAgent = Key<String>("redditAPIUserAgent", default: "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)")
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
