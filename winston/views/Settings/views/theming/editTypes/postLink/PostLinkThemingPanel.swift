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
  @State private var previewPostSampleData = postSampleData
  @Default(.themesPresets) private var themesPresets
  @ObservedObject var tempGlobalState = TempGlobalState.shared
  @Environment(\.colorScheme) private var cs
  @StateObject private var routerProxy = RouterProxy(Router())
  @EnvironmentObject private var redditAPI: RedditAPI
  
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
      PostLink(disableOuterVSpacing: true, post: Post(data: previewPostSampleData, api: redditAPI), sub: Subreddit(id: postSampleData.subreddit, api: redditAPI))
        .equatable()
        .environment(\.useTheme, theme)
        .environmentObject(routerProxy)
        .allowsHitTesting(false)
      
      FakeSection("Options") {
        HStack {
          Toggle("Seen", isOn: Binding(get: {
            previewPostSampleData.winstonSeen ?? false
          }, set: { val in
            previewPostSampleData.winstonSeen = val
          }))
          .onTapGesture {}
          VDivider()
          Toggle("Sticky", isOn: Binding(get: {
            previewPostSampleData.stickied ?? false
          }, set: { val in
            previewPostSampleData.stickied = val
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
