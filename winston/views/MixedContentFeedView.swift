//
//  UserSavedLinks.swift
//  winston
//
//  Created by Ethan Bills on 11/16/23.
//

import Foundation
import SwiftUI
import Defaults

struct MixedContentFeedView: View {
  var mixedMediaLinks: [Either<Post, Comment>]
  @Binding var loadNextData: Bool
  
  @StateObject var user: User
  @State private var loadingOverview = true
  @State private var lastItemId: String? = nil
  @Environment(\.useTheme) private var selectedTheme
  
  @EnvironmentObject private var routerProxy: RouterProxy
  
  @State private var dataTypeFilter: String = "" // Handles filtering for only posts or only comments.
  
  @Binding var reachedEndOfFeed: Bool
  
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
        ForEach(Array(mixedMediaLinks.enumerated()), id: \.self.element) { i, item in
          MixedContentLink(content: item, theme: postLinksTheme, routerProxy: routerProxy)
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
        
        if reachedEndOfFeed {
          EndOfFeedView()
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
