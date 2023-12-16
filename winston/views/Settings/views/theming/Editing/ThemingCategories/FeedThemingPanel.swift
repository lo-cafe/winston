//
//  FeedThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import SwiftUI
import Defaults

struct FeedThemingPanel: View {
  @Binding var theme: WinstonTheme
  @StateObject private var previewPostSample = Post(data: postSampleData)
  @StateObject private var previewPostSubSample = Subreddit(id: postSampleData.subreddit)
  
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
  
  @Environment(\.contentWidth) private var contentWidth
  @Environment(\.colorScheme) private var cs
  
  
  var body: some View {
    ScrollWithPreview(handlerBGOnly: false, theme: theme.postLinks.bg) {
      VStack(spacing: 32) {
        FakeSection("General") {
          LabeledSlider(label: "Posts spacing", value: $theme.postLinks.spacing, range: 0...56)
            .resetter($theme.postLinks.spacing, defaultTheme.postLinks.spacing)
          Divider()
          ThemeBGPicker(bg: $theme.postLinks.bg, defaultVal: defaultTheme.postLinks.bg)
        }
        
        FakeSection("Filters") {
          Toggle("Sticky", isOn: $theme.postLinks.stickyFilters).padding(.horizontal, 16)
          Divider()
          FontSelector(theme: $theme.postLinks.filterText, defaultVal: defaultTheme.postLinks.filterText, showColor: false)
          Divider()
          LabeledSlider(label: "Horizontal Spacing", value: $theme.postLinks.filterPadding.horizontal, range: 0...24)
            .resetter($theme.postLinks.filterPadding.horizontal, defaultTheme.postLinks.filterPadding.horizontal)
          Divider()
          LabeledSlider(label: "Vertical padding", value: $theme.postLinks.filterPadding.vertical, range: 0...24)
            .resetter($theme.postLinks.filterPadding.vertical, defaultTheme.postLinks.filterPadding.vertical)
          Divider()
          LabeledSlider(label: "Opacity", value: $theme.postLinks.filterOpacity, range: 0...1, step: 0.05)
            .resetter($theme.postLinks.filterOpacity, defaultTheme.postLinks.filterOpacity)
        }
        
        FakeSection("Divider") {
          LineThemeEditor(theme: $theme.postLinks.divider, defaultVal: defaultTheme.postLinks.divider)
        }
        .padding(.top, 8)
        
      }
    } preview: {
      ScrollView(showsIndicators: false) {
        if let winstonData = previewPostSample.winstonData {
          VStack(spacing: theme.postLinks.spacing) {
            PostLink(
              id: previewPostSample.id,
              controller: nil,
              theme: theme.postLinks,
              showSub: true,
              secondary: true,
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
              thumbnailPositionRight: nil,
              voteButtonPositionRight: nil,
              showSelfPostThumbnails: showSelfPostThumbnails,
              cs: cs
            )
            .equatable()
            .environment(\.useTheme, theme)
            //            .allowsHitTesting(false)
            
            NiceDivider(divider: theme.postLinks.divider)
            
            PostLink(
              id: previewPostSample.id,
              controller: nil,
              theme: theme.postLinks,
              showSub: true,
              secondary: true,
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
              thumbnailPositionRight: nil,
              voteButtonPositionRight: nil,
              showSelfPostThumbnails: showSelfPostThumbnails,
              cs: cs
            )
            .equatable()
            .environment(\.useTheme, theme)
          }
          .environmentObject(previewPostSample)
          .environmentObject(previewPostSubSample)
          .environmentObject(winstonData)
          .padding(.horizontal, theme.postLinks.theme.outerHPadding)
          .allowsHitTesting(false)
          .contentShape(Rectangle())
          .highPriorityGesture(DragGesture())
        }
      }
      .frame(height: (.screenH - getSafeArea().top - getSafeArea().bottom) / 2, alignment: .top)
      .clipped()
    }
    .onAppear { previewPostSample.setupWinstonData(winstonData: previewPostSample.winstonData, theme: theme) }
    .onChange(of: theme) { x in previewPostSample.setupWinstonData(winstonData: previewPostSample.winstonData, theme: x) }
    .scrollContentBackground(.hidden)
    .themedListBG(theme.lists.bg)
    .navigationTitle("Posts feed")
    .navigationBarTitleDisplayMode(.inline)
  }
}

