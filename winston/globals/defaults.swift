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
  static let redditAPILastTokenRefreshDate = Key<Date?>("redditAPILastTokenRefreshDate", default: nil)
  static let redditAPITokenExpiration = Key<Int?>("redditAPITokenExpiration", default: nil)
  static let multis = Key<[MultiData]>("multis", default: [])
  static let subreddits = Key<[ListingChild<SubredditData>]>("subreddits", default: [])
  static let filteredSubreddits = Key<[String]>("filteredSubreddits", default: [])
  static let postsInBox = Key<[PostInBox]>("postsInBox-v2", default: [])
  static let likedButNotSubbed = Key<[Subreddit]>("likedButNotSubbed", default: [])
  static let preferredSort = Key<SubListingSortOption>("preferredSort", default: .best)
  static let preferredSearchSort = Key<SubListingSortOption>("preferredSearchSort", default: .best)
  static let blurPostLinkNSFW = Key<Bool>("blurPostLinkNSFW", default: true)
  static let blurPostNSFW = Key<Bool>("blurPostNSFW", default: false)
  static let collapseAutoModerator = Key<Bool>("collapseAutoModerator", default: false)
  static let preferredCommentSort = Key<CommentSortOption>("preferredCommentSort", default: .confidence)
  
  // Compact Mode Settings
  static let compactMode = Key<Bool>("compactMode", default: false)
  static let compThumbnailSize = Key<ThumbnailSizeModifier>("compThumbnailSize", default: .small)
  static let thumbnailPositionRight = Key<Bool>("thumbnailPositionRight", default: true)
  static let voteButtonPositionRight = Key<Bool>("voteButtonPositionRight", default: true)
  static let showSelfPostThumbnails = Key<Bool>("showSelfPostThumbnails", default: true)
  static let showAuthorOnPostLinks = Key<Bool>("showAuthorOnPostLinks", default: true)
  
  static let postSwipeActions = Key<SwipeActionsSet>("postSwipeActions", default: DEFAULT_POST_SWIPE_ACTIONS)
  static let commentSwipeActions = Key<SwipeActionsSet>("commentSwipeActions", default: DEFAULT_COMMENT_SWIPE_ACTIONS)
  
  //  static let postLinksOuterHPadding = Key<CGFloat>("postLinksOuterHPadding", default: 0)
  //  static let postLinksOuterVPadding = Key<CGFloat>("postLinksOuterVPadding", default: 8)
  static let postLinksInnerHPadding = Key<CGFloat>("postLinksInnerHPadding", default: 8)
  static let postLinksInnerVPadding = Key<CGFloat>("postLinksInnerVPadding", default: 14)
  static let showUpvoteRatio = Key<Bool>("showUpvoteRatio", default: true)
  
  static let cardedPostLinksOuterHPadding = Key<CGFloat>("cardedPostLinksOuterHPadding", default: 8)
  static let cardedPostLinksOuterVPadding = Key<CGFloat>("cardedPostLinksOuterVPadding", default: 8)
  static let cardedPostLinksInnerHPadding = Key<CGFloat>("cardedPostLinksInnerHPadding", default: 16)
  static let cardedPostLinksInnerVPadding = Key<CGFloat>("cardedPostLinksInnerVPadding", default: 14)
  
  static let commentsInnerHPadding = Key<CGFloat>("commentsInnerHPadding", default: 8)
  static let coloredCommentNames = Key<Bool>("coloredCommentNames", default: false)
  static let showVotes = Key<Bool>("showVotes", default: true)
  static let showSelfText = Key<Bool>("showSelfText", default: true)
  static let cardedCommentsOuterHPadding = Key<CGFloat>("cardedCommentsOuterHPadding", default: 8)
  static let cardedCommentsInnerHPadding = Key<CGFloat>("cardedCommentsInnerHPadding", default: 13)
  
  static let preferenceShowPostsAvatars = Key<Bool>("preferenceShowPostsAvatars", default: true)
  static let preferenceShowPostsCards = Key<Bool>("preferenceShowPostsCards", default: true)
  static let preferenceShowCommentsAvatars = Key<Bool>("preferenceShowCommentsAvatars", default: true)
  static let preferenceShowCommentsCards = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let enableVotesPopover = Key<Bool>("preferenceShowCommentsCards", default: true)
  static let maxPostLinkImageHeightPercentage = Key<Double>("maxPostLinkImageHeightPercentage", default: 100)
  static let replyModalBlurBackground = Key<Bool>("replyModalBlurBackground", default: true)
  static let newPostModalBlurBackground = Key<Bool>("newPostModalBlurBackground", default: true)
  static let showUsernameInTabBar = Key<Bool>("showUsernameInTabBar", default: false)
  static let openYoutubeApp = Key<Bool>("openYoutubeApp", default: true)
  static let preferenceDefaultFeed = Key<String>("preferenceDefaultFeed", default: "subList")
  static let useAuth = Key<Bool>("useAuth", default: false)
  static let showHomeFeed = Key<Bool>("showHomeFeed", default: true)
  static let showPopularFeed = Key<Bool>("showPopularFeed", default: true)
  static let showAllFeed = Key<Bool>("showAllFeed", default: true)
  static let readPostOnScroll = Key<Bool>("readPostOnScroll", default: false)
  static let lightboxViewsPost = Key<Bool>("lightboxViewsPost", default: false)
  static let hideReadPosts = Key<Bool>("hideReadPosts", default: false)
  static let fadeReadPosts = Key<Bool>("fadeReadPosts", default: false)
  static let showSavedFeed = Key<Bool>("showSavedFeed", default: true)
  static let enableSwipeAnywhere = Key<Bool>("enableSwipeAnywhere", default: false)
  static let autoPlayVideos = Key<Bool>("autoPlayVideos", default: true)
  static let loopVideos = Key<Bool>("loopVideos", default: true)
  static let showSubsAtTop = Key<Bool>("showSubsAtTop", default: false)
  static let showTitleAtTop = Key<Bool>("showTitleAtTop", default: true)
  
  static let preferInlineTags = Key<Bool>("preferInlineTags", default: false)
  static let postLinkTitleSize = Key<CGFloat>("postLinkTitleSize", default: 16)
  static let postLinkBodySize = Key<CGFloat>("postLinkBodySize", default: 14)
  static let postViewTitleSize = Key<CGFloat>("postViewTitleSize", default: 20)
  static let postViewBodySize = Key<CGFloat>("postViewBodySize", default: 15)
  static let commentLinkBodySize = Key<CGFloat>("commentLinkBodySize", default: 15)
  
  static let redditAPIUserAgent = Key<String>("redditAPIUserAgent", default: "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)")
  
  static let forceFeedbackModifiers = Key<ForceFeedbackModifiers>("forceFeedbackModifiers", default: .medium)
  static let hapticFeedbackOnLPM = Key<Bool>("hapticFeedbackOnLPM", default: true)
  
  static let openLinksInSafari = Key<Bool>("openLinksInSafari", default: true)
  static let showTestersCelebrationModal = Key<Bool>("showTestersCelebrationModal", default: true)
  static let showTipJarModal = Key<Bool>("showTipJarModal", default: true)
  static let disableAlphabetLettersSectionsInSubsList = Key<Bool>("disableAlphabetLettersSectionsInSubsList", default: false)
  static let themesPresets = Key<[WinstonTheme]>("themesPresets", default: [])
  static let selectedThemeID = Key<String>("selectedThemeID", default: "default")
  static let feedPostsLoadLimit = Key<Int>("feedPostsLoadLimit", default: 35)
  
  static let themeStoreTint = Key<Bool>("themeStoreTint", default: true)
    
  static let perSubredditSort = Key<Bool>("perSubredditSort", default: true)
  static let subredditSorts = Key<Dictionary<String, SubListingSortOption>>("subredditSorts", default: [String: SubListingSortOption]())
    
  static let perPostSort = Key<Bool>("perPostSort", default: true)
  static let postSorts = Key<Dictionary<String, CommentSortOption>>("postSorts", default: [String: CommentSortOption]())
  static let doLiveText = Key<Bool>("doLiveText", default: true)
  
  static let syncKeyChainAndSettings = Key<Bool>("syncKeyChainAndSettings", default: true)
  
  static let shinyTextAndButtons = Key<Bool>("shinyTextAndButtons", default: true)
  
  static let lastSeenAnnouncementTimeStamp = Key<Int>("lastSeenAnnouncementTimeStamp", default: 0)
  static let showingUpsellDict = Key<Dictionary<String, Bool>>("showingUpsellDict", default: [
    "themesUpsell_01": true
  ])
}

extension UIScreen {
  static let screenWidth = UIScreen.main.bounds.size.width
  static let screenHeight = UIScreen.main.bounds.size.height
  static let screenSize = UIScreen.main.bounds.size
}
