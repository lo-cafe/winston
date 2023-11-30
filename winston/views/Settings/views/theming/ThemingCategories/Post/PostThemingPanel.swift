//
//  PostThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI
import Defaults

private enum Category: String, CaseIterable {
  case page, texts, badge
}

private enum PreviewBG: String, CaseIterable {
  case blur, opaque, theme
}

struct PostThemingPanel: View {
  @Binding var theme: WinstonTheme
  @State private var selectedCategory = Category.page.rawValue
  @State private var previewBG: PreviewBG = .blur
  @StateObject private var previewPostSample = Post(data: selfPostSampleData, api: RedditAPI.shared)
  @Default(.themesPresets) private var themesPresets
  @ObservedObject var tempGlobalState = TempGlobalState.shared
  @Environment(\.colorScheme) private var cs
  @StateObject private var routerProxy = RouterProxy(Router(id: "PostThemingPanelRouer"))
  
  
  var body: some View {
    ScrollWithPreview(theme: theme.posts.bg) {
      VStack(alignment: .trailing, spacing: 32) {
        TagsOptionsCarousel($selectedCategory, (Category.allCases.map { $0.rawValue }))
        
        switch selectedCategory {
        case "page":
          PostPageTheming(theme: $theme.posts)
        case "texts":
          PostTextsTheming(theme: $theme.posts)
        case "badge":
          BadgeSettings(theme: $theme.posts.badge, defaultVal: defaultTheme.posts.badge, showSub: true)
        default:
          EmptyView()
        }
        
      }
      .animation(nil, value: selectedCategory)
      .padding(.top, 12)
      .padding(.bottom, 12)
    } preview: {
        VStack(alignment: .leading, spacing: theme.posts.spacing) {
          if let winstonData = previewPostSample.winstonData {
            PostContent(post: previewPostSample, winstonData: winstonData, sub: Subreddit(id: "Apple", api: RedditAPI.shared))
              .environment(\.useTheme, theme)
              .environmentObject(routerProxy)
              .allowsHitTesting(false)
          }
        }
        .padding(.horizontal, theme.posts.padding.horizontal)
        .padding(.vertical, theme.posts.padding.vertical)
    }
    .themedListBG(theme.lists.bg)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .navigationTitle("Post page")
    .navigationBarTitleDisplayMode(.inline)
  }
}
