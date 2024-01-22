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
  var previewPostSample: Post
  @State private var selectedCategory = "card"
  @State private var previewPostSubSample = Subreddit(id: postSampleData.subreddit)
  
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  
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
          BadgeSettings(theme: $theme.postLinks.theme.badge, defaultVal: defaultTheme.postLinks.theme.badge, showSub: true)
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
          PostLink(id: previewPostSample.id, theme: theme.postLinks, showSub: true, secondary: false, compactPerSubreddit: nil, contentWidth: contentWidth, defSettings: postLinkDefSettings)
//          .equatable()
            .environment(\.contextPost, previewPostSample)
            .environment(\.contextSubreddit, previewPostSubSample)
            .environment(\.contextPostWinstonData, winstonData)
//          .environment(\.useTheme, theme)
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
    .onAppear { previewPostSample.setupWinstonData(winstonData: previewPostSample.winstonData, theme: theme) }
    .onChange(of: theme) { x in previewPostSample.setupWinstonData(winstonData: previewPostSample.winstonData, theme: x) }
    .themedListBG(theme.lists.bg)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .navigationTitle("Posts links")
    .navigationBarTitleDisplayMode(.inline)
  }
}
