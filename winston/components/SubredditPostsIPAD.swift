//
//  SubredditPostsIPAD.swift
//  winston
//
//  Created by Igor Marcossi on 28/09/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import NukeUI

//struct SubredditPostsIPAD: View, Equatable {
//  static func == (lhs: SubredditPostsIPAD, rhs: SubredditPostsIPAD) -> Bool {
//    lhs.posts.count == rhs.posts.count && lhs.subreddit == rhs.subreddit && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.lastPostAfter == rhs.lastPostAfter && lhs.filter == rhs.filter && lhs.loading == rhs.loading
//  }
//  
//  var showSub = false
//  var lastPostAfter: String?
//  var subreddit: Subreddit?
////  var filters: [FilterData]
//  var posts: [Post]
//  var filter: String
////  var filterCallback: ((String) -> ())
//  var searchText: String
////  var searchCallback: ((String?) -> ())
////  var editCustomFilter: ((FilterData) -> ())
//  var fetch: (Bool, String?, Bool) -> ()
//  var selectedTheme: WinstonTheme
//  var loading: Bool
//  
//  @State var lastPostOnRefreshRequest = ""
//  @Binding var reachedEndOfFeed: Bool
//  
//  @Environment(\.contentWidth) var contentWidth
//  
//  @Default(.PostLinkDefSettings) private var postLinkDefSettings
//  @Default(.SubredditFeedDefSettings) private var feedDefSettings
//  
//  func loadMorePosts() {
//    if !searchText.isEmpty {
//      fetch(true, searchText, true)
//    } else {
//      fetch(true, nil, true)
//    }
//  }
//  
//  var body: some View {
//    let isFiltered = filter != "flair:All"
//    Waterfall(
//      collection: posts,
//      scrollDirection: .vertical,
//      contentSize: .custom({ collectionView, layout, post in
//        post.winstonData?.postDimensions.size ?? CGSize(width: 300, height: 300)
//      }),
//      //          itemSpacing: .init(mainAxisSpacing: selectedTheme.postLinks.spacing, crossAxisSpacing: selectedTheme.postLinks.spacing),
//      //          itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 0),
//      contentForData: { post, i in
//        Group {
//          if let sub = subreddit ?? post.winstonData?.subreddit, let winstonData = post.winstonData {
//            PostLink(id: post.id, theme: selectedTheme.postLinks, showSub: showSub, compactPerSubreddit: feedDefSettings.compactPerSubreddit[sub.id], contentWidth: contentWidth, defSettings: postLinkDefSettings)
//              .id(post.id)
//              .environment(\.contextPost, post)
//              .environment(\.contextSubreddit, sub)
//              .environment(\.contextPostWinstonData, winstonData)
//              .onAppear {
//                if(posts.count - 7 == i && !isFiltered && !loading) { loadMorePosts() }
//              }
//          }
//          if isFiltered && !loading && !reachedEndOfFeed && i == posts.count - 1  {
//            Button(action: {
//              loadMorePosts()
//            }) {
//              Label("LOAD MORE", systemImage: "arrow.clockwise.circle.fill")
//                .frame(maxWidth: .infinity, minHeight: 50, alignment: .top)
//                .font(Font.system(size: 16, weight: .bold))
//                .foregroundStyle(selectedTheme.general.accentColor())
//              //.padding(.top, 12)
//              //.padding(.bottom, 48)
//            }
//          }
//          
//          if reachedEndOfFeed && i == posts.count - 1 {
//            EndOfFeedView()
//              .frame(maxWidth: .infinity, maxHeight: 50)
//          }
//        }
//      },
//      theme: selectedTheme.postLinks
//    )
////    .ignoresSafeArea(.all)
//    .floatingMenu(subId: subreddit?.id ?? "", filters: filters, selected: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: editCustomFilter)
//    .overlay {
//      if loading {
//        ProgressView()
//          .progressViewStyle(.circular)
//          .frame(maxWidth: .infinity, minHeight: (posts.count > 0 || isFiltered) ? 50 : .screenH - 200 )
//          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//          .listRowSeparator(.hidden)
//          .listSectionSeparator(.hidden)
//          .listRowBackground(Color.clear)
//          .id(UUID())
//      } else if isFiltered && posts.count == 0 {
//        Text("No filtered posts")
//          .frame(maxWidth: .infinity)
//          .font(Font.system(size: 22, weight: .semibold))
//          .opacity(0.5)
//          .padding(.vertical, 24)
//          .background(RR(12, Color.primary.opacity(0.1)))
//        if !reachedEndOfFeed {
//          Button(action: {
//            loadMorePosts()
//          }) {
//            Label("LOAD MORE", systemImage: "arrow.clockwise.circle.fill")
//              .frame(maxWidth: .infinity)
//              .font(Font.system(size: 16, weight: .bold))
//              .foregroundStyle(selectedTheme.general.accentColor())
//              .padding(.top, 12)
//              .padding(.bottom, 48)
//          }
//        }
//      }
//    }
//    .ignoresSafeArea(.all)
//		.floatingMenu(subId: subreddit?.id ?? "", filters: filters, selected: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: editCustomFilter)
//  }
//}
