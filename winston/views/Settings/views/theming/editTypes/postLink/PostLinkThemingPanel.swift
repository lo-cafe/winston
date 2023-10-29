//
//  PostLinkThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI
import Defaults

private enum Category: String, CaseIterable {
  case card, texts, badge
}

struct PostLinkThemingPanel: View {
  @Binding var theme: WinstonTheme
  @State private var selectedCategory = "card"
  @StateObject private var previewPostSample = Post(data: postSampleData, api: RedditAPI.shared)
  @StateObject private var previewPostSubSample = Subreddit(id: postSampleData.subreddit, api: RedditAPI.shared)
  @Default(.themesPresets) private var themesPresets
  @ObservedObject var tempGlobalState = TempGlobalState.shared
  @Environment(\.colorScheme) private var cs
  @StateObject private var routerProxy = RouterProxy(Router(id: "PostLinkThemingPanelRouter"))
  
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
  
  @ObservedObject var avatarCache = Caches.avatars
  @Environment(\.contentWidth) private var contentWidth
  
  var body: some View {
    
//    ScrollWithPreview(theme: theme.postLinks.bg) {
    ScrollWithPreview(theme: theme.postLinks.bg) {
      VStack(alignment: .trailing, spacing: 24) {
        TagsOptionsCarousel($selectedCategory, (Category.allCases.map { $0.rawValue }))
        
        switch selectedCategory {
        case "card":
          CardSettings(theme: $theme.postLinks.theme)
        case "texts":
          TextsSettings(theme: $theme.postLinks.theme)
        case "badge":
          BadgeSettings(theme: $theme.postLinks.theme.badge, defaultVal: defaultTheme.postLinks.theme.badge)
        default:
          EmptyView()
        }
        
      }
//      .animation(nil, value: selectedCategory)
      .padding(.top, 12)
      .padding(.bottom, 12)
    } preview: {
      
      VStack {
        if let winstonData = previewPostSample.winstonData {
          PostLink(
            id: previewPostSample.id,
            controller: nil,
            avatarRequest: avatarCache.cache["t2_winston_sample"]?.data,
            theme: theme.postLinks,
            showSub: true,
            secondary: true,
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
            compact: false,
            thumbnailPositionRight: nil,
            voteButtonPositionRight: nil,
            cs: cs
          )
          .equatable()
          .environmentObject(previewPostSample)
          .environmentObject(previewPostSubSample)
          .environmentObject(winstonData)
          .environment(\.useTheme, theme)
          .allowsHitTesting(false)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      
      FakeSection("Options") {
        HStack {
          Toggle("Seen", isOn: Binding(get: {
            previewPostSample.data?.winstonSeen ?? false
          }, set: { val in
            previewPostSample.data?.winstonSeen = val
          }))
          .onTapGesture {}
          VDivider()
          Toggle("Sticky", isOn: Binding(get: {
            previewPostSample.data?.stickied ?? false
          }, set: { val in
            previewPostSample.data?.stickied = val
          }))
          .onTapGesture {}
        }
        .padding(.horizontal, 16)
      }
      
      
    }
    .themedListBG(theme.lists.bg)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .navigationTitle("Posts links")
    .navigationBarTitleDisplayMode(.inline)
  }
}
