//
//  MultiPostsView.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect

enum MultiViewType: Hashable {
  case posts(Multi)
  case info(Multi)
}

struct MultiPostsView: View {
  @ObservedObject var multi: Multi
  @State private var loading = true
  @StateObject private var posts = NonObservableArray<Post>()
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption = Defaults[.preferredSort]
  @State private var newPost = false
  @State private var reachedEndOfFeed: Bool = false
  
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false) async {
    //    if (multi.data == nil || force) {
    //      await multi.refreshSubreddit()
    //    }
    if posts.data.count > 0 && lastPostAfter == nil && !force {
      return
    }
    if let result = await multi.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil, contentWidth: contentWidth), let newPosts = result.0 {
      withAnimation {
        if loadMore {
          posts.data.append(contentsOf: newPosts)
        } else {
          posts.data = newPosts
        }
        loading = false
        lastPostAfter = result.1
        reachedEndOfFeed = newPosts.count == 0
      }
      Task(priority: .background) {
        await RedditAPI.shared.updatePostsWithAvatar(posts: newPosts, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size)
      }
    }
  }
  
  func fetch(loadMore: Bool = false, _ searchText: String? = nil) {
    Task(priority: .background) {
      await asyncFetch(loadMore: loadMore)
    }
  }
  
  var body: some View {
    Group {
      if IPAD {
        SubredditPostsIPAD(showSub: true, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme)
      } else {
        SubredditPostsIOS(showSub: true, lastPostAfter: lastPostAfter, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme, reachedEndOfFeed: $reachedEndOfFeed)
      }
    }
    //.themedListBG(selectedTheme.postLinks.bg)
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 1)
    .loader(loading && posts.data.count == 0 && !reachedEndOfFeed)
    .navigationBarItems(
      trailing:
        HStack {
          Menu {
            ForEach(SubListingSortOption.allCases) { opt in
              Button {
                sort = opt
              } label: {
                HStack {
                  Text(opt.rawVal.value.capitalized)
                  Spacer()
                  Image(systemName: opt.rawVal.icon)
                    .foregroundColor(Color.accentColor)
                    .fontSize(17, .bold)
                }
              }
            }
          }
        label: {
            Image(systemName: sort.rawVal.icon)
              .foregroundColor(Color.accentColor)
              .fontSize(17, .bold)
          }
          
          if let imgLink = multi.data?.icon_url, let imgURL = URL(string: imgLink) {
            Button {
//              routerProxy.router.path.append(SubViewType.info(subreddit))
            } label: {
              URLImage(url: imgURL)
                .scaledToFill()
                .frame(width: 30, height: 30)
                .mask(Circle())
            }
          }
        }
        .animation(nil, value: sort)
    )
    .onAppear {
      if posts.data.count == 0 {
        doThisAfter(0.0) {
          fetch()
        }
      }
    }
    .onChange(of: sort) { val in
      withAnimation {
        loading = true
        posts.data.removeAll()
        reachedEndOfFeed = false
      }
      fetch()
      Defaults[.preferredSort] = sort
    }
//    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .refreshable { await asyncFetch(force: true) }
    .navigationTitle(multi.data?.name ?? "MultiZ")
    .scrollContentBackground(.hidden)
    //.background(.thinMaterial)
  }
  
}
