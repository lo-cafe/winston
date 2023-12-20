//
//  oldDefaults.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Foundation
import Defaults
import UIKit
import SwiftUI


/* These are the acient defaults, DO NOT INCLUDE ANYTHING NEW IN HERE.
 * They're here just for migration purposes.
 * They're all now marked with the cursed sign of underl...
 * (I won't pronnounce such words here) so they're bound to the destiny
 * of being avoided because _ looks ugly and hacky anywhere. */
extension Defaults.Keys {
  static let _redditCredentialSelectedID = Key<UUID?>("redditCredentialSelectedID", default: nil)
  static let _redditAPILastTokenRefreshDate = Key<Date?>("redditAPILastTokenRefreshDate", default: nil)
  static let _redditAPITokenExpiration = Key<Int?>("redditAPITokenExpiration", default: nil)
//  static let filteredSubreddits = Key<[String]>("filteredSubreddits", default: [])
//  static let postsInBox = Key<[PostInBox]>("postsInBox-v2", default: [])
//  static let likedButNotSubbed = Key<[Subreddit]>("likedButNotSubbed", default: [])
  static let _preferredSort = Key<SubListingSortOption>("preferredSort", default: .best)
  static let _preferredSearchSort = Key<SubListingSortOption>("preferredSearchSort", default: .best)
  static let _blurPostLinkNSFW = Key<Bool>("blurPostLinkNSFW", default: true)
  static let _blurPostNSFW = Key<Bool>("blurPostNSFW", default: false)
  static let _collapseAutoModerator = Key<Bool>("collapseAutoModerator", default: false)
  static let _preferredCommentSort = Key<CommentSortOption>("preferredCommentSort", default: .confidence)
  static let _tappableFeedMedia = Key<Bool>("tappableFeedMedia", default: true)
  
  // CompdismissKeyboardt Mode Settings
  static let _compactMode = Key<Bool>("compactMode", default: false)
  static let _compactPerSubreddit = Key<Dictionary<String, Bool>>("compactPerSubreddit", default: [:])
  static let _compThumbnailSize = Key<ThumbnailSizeModifier>("compThumbnailSize", default: .small)
  static let _thumbnailPositionRight = Key<Bool>("thumbnailPositionRight", default: true)
  static let _voteButtonPositionRight = Key<Bool>("voteButtonPositionRight", default: true)
  static let _showSelfPostThumbnails = Key<Bool>("showSelfPostThumbnails", default: true)
  static let _showAuthorOnPostLinks = Key<Bool>("showAuthorOnPostLinks", default: true)
  
  static let _postSwipeActions = Key<SwipeActionsSet>("postSwipeActions", default: DEFAULT_POST_SWIPE_ACTIONS)
  static let _commentSwipeActions = Key<SwipeActionsSet>("commentSwipeActions", default: DEFAULT_COMMENT_SWIPE_ACTIONS)
  
  static let _showUpvoteRatio = Key<Bool>("showUpvoteRatio", default: true)
  
  static let _coloredCommentNames = Key<Bool>("coloredCommentNames", default: false)
  static let _showVotes = Key<Bool>("showVotes", default: true)
  static let _showSelfText = Key<Bool>("showSelfText", default: true)
  
  static let _enableVotesPopover = Key<Bool>("enableVotesPopover", default: true)
  static let _maxPostLinkImageHeightPercentage = Key<Double>("maxPostLinkImageHeightPercentage", default: 100)
  static let _replyModalBlurBackground = Key<Bool>("replyModalBlurBackground", default: true)
  static let _newPostModalBlurBackground = Key<Bool>("newPostModalBlurBackground", default: true)
  static let _showUsernameInTabBar = Key<Bool>("showUsernameInTabBar", default: false)
  static let _openYoutubeApp = Key<Bool>("openYoutubeApp", default: true)
  static let _preferenceDefaultFeed = Key<String>("preferenceDefaultFeed", default: "subList")
  static let _useAuth = Key<Bool>("useAuth", default: false)
  static let _readPostOnScroll = Key<Bool>("readPostOnScroll", default: false)
  static let _lightboxViewsPost = Key<Bool>("lightboxViewsPost", default: false)
  static let _hideReadPosts = Key<Bool>("hideReadPosts", default: false)
  static let _enableSwipeAnywhere = Key<Bool>("enableSwipeAnywhere", default: false)
  static let _autoPlayVideos = Key<Bool>("autoPlayVideos", default: true)
  static let _muteVideos = Key<Bool>("muteVideos", default: false)
  static let _pauseBackgroundAudioOnFullscreen = Key<Bool>("pauseBackgroundAudioOnFullscreen", default: true)
  static let _loopVideos = Key<Bool>("loopVideos", default: true)
  static let _showSubsAtTop = Key<Bool>("showSubsAtTop", default: false)
  static let _showTitleAtTop = Key<Bool>("showTitleAtTop", default: true)
  
  static let _redditAPIUserAgent = Key<String>("redditAPIUserAgent", default: "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)")
  
  static let _openLinksInSafari = Key<Bool>("openLinksInSafari", default: true)
  static let _showTestersCelebrationModal = Key<Bool>("showTestersCelebrationModal", default: true)
  static let _showTipJarModal = Key<Bool>("showTipJarModal", default: true)
  static let _disableAlphabetLettersSectionsInSubsList = Key<Bool>("disableAlphabetLettersSectionsInSubsList", default: false)
  static let _themesPresets = Key<[WinstonTheme]>("themesPresets", default: [])
  static let _selectedThemeID = Key<String>("selectedThemeID", default: "default")
  static let _feedPostsLoadLimit = Key<Int>("feedPostsLoadLimit", default: 35)
  
  static let _themeStoreTint = Key<Bool>("themeStoreTint", default: true)
  
  static let _perSubredditSort = Key<Bool>("perSubredditSort", default: true)
  static let _subredditSorts = Key<Dictionary<String, SubListingSortOption>>("subredditSorts", default: [String: SubListingSortOption]())
  
  static let _perPostSort = Key<Bool>("perPostSort", default: true)
  static let _postSorts = Key<Dictionary<String, CommentSortOption>>("postSorts", default: [String: CommentSortOption]())
  static let _doLiveText = Key<Bool>("doLiveText", default: true)
  
  static let _syncKeyChainAndSettings = Key<Bool>("syncKeyChainAndSettings", default: true)
  
  static let _shinyTextAndButtons = Key<Bool>("shinyTextAndButtons", default: true)
  
  static let _lastSeenAnnouncementTimeStamp = Key<Int>("lastSeenAnnouncementTimeStamp", default: 0)
  static let _showingUpsellDict = Key<Dictionary<String, Bool>>("showingUpsellDict", default: [
    "themesUpsell_01": true
  ])
}
