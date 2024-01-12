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
  @State private var sort: SubListingSortOption = Defaults[.SubredditFeedDefSettings].preferredSort
  @State private var newPost = false
  @State private var filter: String = "flair:All"
  @State private var customFilter: FilterData?
  @State private var reachedEndOfFeed: Bool = false
  
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
//  @Environment(\.colorScheme) private var cs
	@Environment(\.horizontalSizeClass) private var hSizeClass
  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
  
  func searchCallback(str: String?) {
    searchText = str ?? ""
    clearAndReloadData()
  }
  
  func filterCallback(str: String) {
    filter = str
  }
  
  func editCustomFilter(filterData: FilterData) {
    customFilter = filterData
  }
  
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
  
  func fetch(loadMore: Bool = false, _ searchText: String? = nil, forceRefresh: Bool = false) {
    Task(priority: .background) {
      await asyncFetch(loadMore: loadMore)
    }
  }
  
  func clearAndReloadData() {
    withAnimation {
      loading = true
      posts.data.removeAll()
      reachedEndOfFeed = false
    }
    
    fetch()
  }
  
  func updatePostsCalcs(_ newTheme: WinstonTheme) {
    Task(priority: .background) { posts.data.forEach { $0.setupWinstonData(data: $0.data, winstonData: $0.winstonData, contentWidth: contentWidth, secondary: false, theme: selectedTheme, sub: $0.winstonData?.subreddit, fetchAvatar: false) } }
  }
  
  var body: some View {
    Group {
      if IPAD && hSizeClass == .regular {
        SubredditPostsIPAD(showSub: true, lastPostAfter: lastPostAfter, filters: [], posts: posts.data, filter: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter, fetch: fetch, selectedTheme: selectedTheme, loading: loading, reachedEndOfFeed: $reachedEndOfFeed)
      } else {
        SubredditPostsIOS(showSub: true, lastPostAfter: lastPostAfter, filters: [], posts: posts.data, filter: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter, fetch: fetch, selectedTheme: selectedTheme, loading: loading, reachedEndOfFeed: $reachedEndOfFeed)
      }
    }
    //.themedListBG(selectedTheme.postLinks.bg)
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 1)
    //.loader(loading && posts.data.count == 0 && !reachedEndOfFeed)
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
    .onChange(of: sort) { _ in clearAndReloadData() }
//    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
//    .onChange(of: cs) { _ in updatePostsCalcs(selectedTheme) }
    .onChange(of: subredditFeedDefSettings.compactPerSubreddit) { _ in updatePostsCalcs(selectedTheme) }
    .onChange(of: selectedTheme, perform: updatePostsCalcs)
    .refreshable { await asyncFetch(force: true) }
    .navigationTitle(multi.data?.name ?? "MultiZ")
    .scrollContentBackground(.hidden)
    //.background(.thinMaterial)
  }
  
}
