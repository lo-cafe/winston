//
//  SubredditPostsIPAD.swift
//  winston
//
//  Created by Igor Marcossi on 28/09/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect

struct SubredditPostsIPAD: View, Equatable {
  static func == (lhs: SubredditPostsIPAD, rhs: SubredditPostsIPAD) -> Bool {
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme
  }
  
  var showSub = false
  var subreddit: Subreddit?
  var posts: [Post]
  var searchText: String
  var fetch: (Bool, String?) -> ()
  var selectedTheme: WinstonTheme
  @Environment(\.contentWidth) var contentWidth
  
  var body: some View {
        Waterfall(
          collection: posts,
          scrollDirection: .vertical,
          contentSize: .custom({ collectionView, layout, post in
            post.winstonData?.postDimensions?.size ?? CGSize(width: 300, height: 300)
          }),
//          itemSpacing: .init(mainAxisSpacing: selectedTheme.postLinks.spacing, crossAxisSpacing: selectedTheme.postLinks.spacing),
//          itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 0),
          contentForData: { post, i in
            Group {
              if let sub = subreddit ?? post.winstonData?.subreddit {
                PostLink(post: post, sub: sub, showSub: showSub)
                  .equatable()
                  .onAppear {
                    if(posts.count - 15 == i) {
                      if !searchText.isEmpty {
                        fetch(true, searchText)
                      } else {
                        fetch(true, nil)
                      }
                    }
                  }
              }
            }
          },
          theme: selectedTheme.postLinks
        )
        .ignoresSafeArea()
//      .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
//        scrollView.backgroundColor = UIColor.systemGroupedBackground
//      }
  }
}
