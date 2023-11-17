//
//  SubredditPostsIOS.swift
//  winston
//
//  Created by Igor Marcossi on 28/09/23.
//

import SwiftUI

struct SubredditPostsIOS: View, Equatable {
  static func == (lhs: SubredditPostsIOS, rhs: SubredditPostsIOS) -> Bool {
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.lastPostAfter == rhs.lastPostAfter
  }
  
  var showSub = false
  var lastPostAfter: String?
  var subreddit: Subreddit?
  var posts: [Post]
  var searchText: String
  var fetch: (Bool, String?) -> ()
  var selectedTheme: WinstonTheme
  var body: some View {
    let paddingH = selectedTheme.postLinks.theme.outerHPadding
    let paddingV = selectedTheme.postLinks.spacing / 2
    List {
      
      
      Section {
        ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in
          
          if let sub = subreddit ?? post.winstonData?.subreddit {
            PostLink(post: post, sub: sub, showSub: showSub)
              .equatable()
              .onAppear {
                if(posts.count - 7 == i) {
                  if !searchText.isEmpty {
                    fetch(true, searchText)
                  } else {
                    fetch(true, nil)
                  }
                }
              }
              .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
          }
          
          if selectedTheme.postLinks.divider.style != .no && i != (posts.count - 1) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
              .id("\(post.id)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
          
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      
      Section {
        if lastPostAfter != nil {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: posts.count > 0 ? 100 : UIScreen.screenHeight - 200 )
            .id("post-loading")
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
      }
      
    }
    .themedListBG(selectedTheme.postLinks.bg)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 1)
  }
}
