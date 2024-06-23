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
  var newCommentsCount: Int?
  var createdAt: Double?
  var lastUpdatedAt: Double?
}

let DEFAULT_POST_SWIPE_ACTIONS = SwipeActionsSet(
  id: "post-swipe-actions",
  leftFirst: AnySwipeAction(UpvotePostAction()),
  leftSecond: AnySwipeAction(SavePostAction()),
  rightFirst: AnySwipeAction(DownvotePostAction()),
  rightSecond: AnySwipeAction(SeenPostAction())
)

let DEFAULT_COMMENT_SWIPE_ACTIONS = SwipeActionsSet(
  id: "comment-swipe-actions",
  leftFirst: AnySwipeAction(UpvoteCommentAction()),
  leftSecond: AnySwipeAction(SaveCommentAction()),
  rightFirst: AnySwipeAction(DownvoteCommentAction()),
  rightSecond: AnySwipeAction(ReplyCommentAction())
)

extension Defaults.Keys {
  static let PostLinkDefSettings = Key<PostLinkDefSettings>("PostLinkDefSettings", default: .init())
  static let VideoDefSettings = Key<VideoDefSettings>("VideoDefSettings", default: .init())
  static let AppearanceDefSettings = Key<AppearanceDefSettings>("AppearanceDefSettings", default: .init())
  static let BehaviorDefSettings = Key<BehaviorDefSettings>("BehaviorDefSettings", default: .init())
  static let GeneralDefSettings = Key<GeneralDefSettings>("GeneralDefSettings", default: .init())
  static let SubredditFeedDefSettings = Key<SubredditFeedDefSettings>("SubredditFeedDefSettings", default: .init())
  static let CommentLinkDefSettings = Key<CommentLinkDefSettings>("CommentLinkDefSettings", default: .init())
  static let CommentsSectionDefSettings = Key<CommentsSectionDefSettings>("CommentsSectionDefSettings", default: .init())
  static let PostPageDefSettings = Key<PostPageDefSettings>("PostPageDefSettings", default: .init())
  static let ThemesDefSettings = Key<ThemesDefSettings>("ThemesDefSettings", default: .init())
  static let TipJarSettings = Key<TipJarSettings>("TipJarSettings", default: .init())
  
  /* <Heavy Defaults are kept separated, these should be in CoreData or something> */
  static let filteredSubreddits = Key<[String]>("filteredSubreddits", default: [])
  static let postsInBox = Key<[PostInBox]>("postsInBox-v2", default: [])
  static let likedButNotSubbed = Key<[Subreddit]>("likedButNotSubbed", default: [])
  /* </Heavy Defaults are kept separated, these should be in CoreData or something> */
  
  static let wereOldDefaultsMigrated = Key<Bool>("wereOldDefaultsMigrated", default: false)
}
