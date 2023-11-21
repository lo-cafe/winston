//
//  UserSavedLinks.swift
//  winston
//
//  Created by Ethan Bills on 11/16/23.
//

import Foundation
import SwiftUI
import Defaults

struct MixedMediaFeedLinksView: View {
  var mixedMediaLinks: [Either<Post, Comment>]
  @Binding var loadNextData: Bool
  
  @StateObject var user: User
  @State private var contentWidth: CGFloat = 0
  @State private var loadingOverview = true
  @State private var lastItemId: String? = nil
  @Environment(\.useTheme) private var selectedTheme
  @EnvironmentObject private var routerProxy: RouterProxy
  
  @State private var dataTypeFilter: String = "" // Handles filtering for only posts or only comments.
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  @Default(.showSelfPostThumbnails) private var showSelfPostThumbnails
  
  @Environment(\.colorScheme) private var cs
  
  func updateContentsCalcs(_ newTheme: WinstonTheme) {
    Task(priority: .background) {
      mixedMediaLinks.forEach {
        switch $0 {
        case .first(let post):
          post.setupWinstonData(data: post.data, winstonData: post.winstonData, theme: newTheme, fetchAvatar: false)
        case .second(let comment):
          comment.setupWinstonData()
          break
        }
      }
    }
  }
  
  var body: some View {
    let postLinksTheme = selectedTheme.postLinks
    let isThereDivider = selectedTheme.postLinks.divider.style != .no
    let paddingH = postLinksTheme.theme.outerHPadding
    let paddingV = postLinksTheme.spacing / (isThereDivider ? 4 : 2)
    
    List {
      Section {
        ForEach(Array(mixedMediaLinks.enumerated()), id: \.self.element.hashValue) { i, item in
          Group {
            switch item {
            case .first(let post):
              if let postData = post.data, let winstonData = post.winstonData {
                PostLink(
                  id: post.id,
                  controller: nil,
                  theme: selectedTheme.postLinks,
                  showSub: true,
                  routerProxy: routerProxy,
                  contentWidth: contentWidth,
                  blurPostLinkNSFW: blurPostLinkNSFW,
                  postSwipeActions: postSwipeActions,
                  showVotes: showVotes,
                  showSelfText: showSelfText,
                  readPostOnScroll: readPostOnScroll,
                  hideReadPosts: hideReadPosts,
                  showUpvoteRatio: showUpvoteRatio,
                  showSubsAtTop: showSubsAtTop,
                  showTitleAtTop: showTitleAtTop,
                  compact: compactMode,
                  thumbnailPositionRight: thumbnailPositionRight,
                  voteButtonPositionRight: voteButtonPositionRight,
                  showSelfPostThumbnails: showSelfPostThumbnails,
                  cs: cs
                )
                .environmentObject(post)
                .environmentObject(Subreddit(id: postData.subreddit, api: user.redditAPI))
                .environmentObject(winstonData)
              }
            case .second(let comment):
              VStack {
                ShortCommentPostLink(comment: comment)
                if let commentWinstonData = comment.winstonData {
                  CommentLink(lineLimit: 3, showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                }
              }
              .padding(.horizontal, 12)
              .padding(.top, 12)
              .padding(.bottom, 10)
              .background(PostLinkBG(theme: postLinksTheme, stickied: false, secondary: false, cs: cs).equatable())
              .mask(RR(postLinksTheme.theme.cornerRadius, Color.black).equatable())
            }
          }
          .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
          .onAppear {
            if mixedMediaLinks.count > 0 && (Int(Double(mixedMediaLinks.count) * 0.75) == i) {
              loadNextData = true
            }
          }
          
          if selectedTheme.postLinks.divider.style != .no && i != (mixedMediaLinks.count - 1) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
              .id("mixed-media-\(i)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .environment(\.defaultMinListRowHeight, 1)
    }
    .onChange(of: cs) { _ in
      updateContentsCalcs(selectedTheme)
    }
    .onChange(of: selectedTheme, perform: updateContentsCalcs)
    .themedListBG(selectedTheme.postLinks.bg)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
  }
}
