//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect


enum SubViewType: Hashable {
  case posts(Subreddit)
  case info(Subreddit)
}

struct SubredditPosts: View, Equatable {
  static func == (lhs: SubredditPosts, rhs: SubredditPosts) -> Bool {
    lhs.subreddit.id == rhs.subreddit.id
  }
  
  @ObservedObject var subreddit: Subreddit
  @Default(.filteredSubreddits) private var filteredSubreddits
  @State private var loading = true
  @StateObject private var posts = NonObservableArray<Post>()
  @State private var loadedPosts: Set<String> = []
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption = Defaults[.preferredSort]
  @State private var newPost = false
  
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @Environment(\.contentWidth) private var contentWidth
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false, searchText: String? = nil) async {
    if (subreddit.data == nil || force) && !feedsAndSuch.contains(subreddit.id) {
      await subreddit.refreshSubreddit()
    }
    if posts.data.count > 0 && lastPostAfter == nil && !force {
      return
    }
    withAnimation {
      loading = true
    }
    if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil, searchText: searchText, contentWidth: contentWidth), let newPosts = result.0 {
      withAnimation {
        //        let newPostsFiltered = newPosts.filter { !loadedPosts.contains($0.id) && !filteredSubreddits.contains($0.data?.subreddit ?? "") }
        
        if loadMore {
          //          posts.data.append(contentsOf: newPostsFiltered)
          posts.data.append(contentsOf: newPosts)
        } else {
          //          posts.data = newPostsFiltered
          posts.data = newPosts
        }
        
        //        newPostsFiltered.forEach { loadedPosts.insert($0.id) }
        
        loading = false
        lastPostAfter = result.1
      }
      Task(priority: .background) {
        await RedditAPI.shared.updateAvatarURLCacheFromPosts(posts: newPosts, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size)
      }
    }
  }
  
  func fetch(_ loadMore: Bool = false, _ searchText: String? = nil) {
    Task(priority: .background) {
      await asyncFetch(loadMore: loadMore, searchText: searchText)
    }
  }
  
  func clearAndLoadData(withSearchText searchText: String? = nil) {
    withAnimation {
      posts.data.removeAll()
      loadedPosts.removeAll()
    }
    
    if let searchText = searchText, !searchText.isEmpty {
      fetch(false, searchText)
    } else {
      fetch()
    }
    
  }
  
  var body: some View {
    Group {
      if IPAD {
        SubredditPostsIPAD(subreddit: subreddit, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme)
      } else {
        SubredditPostsIOS(lastPostAfter: lastPostAfter, subreddit: subreddit, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme)
      }
    }
    .loader(loading && posts.data.count == 0)
    .overlay(
      feedsAndSuch.contains(subreddit.id)
      ? nil
      : Button {
        newPost = true
      } label: {
        Image(systemName: "newspaper.fill")
          .fontSize(22, .bold)
          .frame(width: 64, height: 64)
          .foregroundColor(Color.accentColor)
          .floating()
          .contentShape(Circle())
      }
        .buttonStyle(NoBtnStyle())
        .shrinkOnTap()
        .padding(.all, 12)
      , alignment: .bottomTrailing
    )
    .sheet(isPresented: $newPost, content: {
      NewPostModal(subreddit: subreddit)
    })
    .navigationBarItems(trailing: SubredditPostsNavBtns(sort: $sort, subreddit: subreddit, routerProxy: routerProxy))
    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .onSubmit(of: .search) {
      clearAndLoadData(withSearchText: searchText)
    }
    .refreshable {
      loadedPosts.removeAll()
      await asyncFetch(force: true)
    }
    .navigationTitle("\(feedsAndSuch.contains(subreddit.id) ? subreddit.id.capitalized : "r/\(subreddit.data?.display_name ?? subreddit.id)")")
    .task(priority: .background) {
      if posts.data.count == 0 { await asyncFetch() }
    }
    .onChange(of: sort) { val in
      clearAndLoadData()
    }
    .onChange(of: searchText) { val in
      if searchText.isEmpty {
        clearAndLoadData()
      }
    }
  }
  
}


struct SubredditPostsNavBtns: View, Equatable {
  static func == (lhs: SubredditPostsNavBtns, rhs: SubredditPostsNavBtns) -> Bool {
    lhs.sort == rhs.sort && lhs.subreddit.data.isNil == rhs.subreddit.data.isNil
  }
  @Binding var sort: SubListingSortOption
  @ObservedObject var subreddit: Subreddit
  var routerProxy: RouterProxy
  var body: some View {
    HStack {
      Menu {
        ForEach(SubListingSortOption.allCases) { opt in
          if case .top(_) = opt {
            Menu {
              ForEach(SubListingSortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
                Button {
                  sort = .top(topOpt)
                } label: {
                  HStack {
                    Text(topOpt.rawValue.capitalized)
                    Spacer()
                    Image(systemName: topOpt.icon)
                      .foregroundColor(Color.accentColor)
                      .font(.system(size: 17, weight: .bold))
                  }
                }
              }
            } label: {
              Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                .foregroundColor(Color.accentColor)
                .font(.system(size: 17, weight: .bold))
            }
          } else {
            Button {
              sort = opt
            } label: {
              HStack {
                Text(opt.rawVal.value.capitalized)
                Spacer()
                Image(systemName: opt.rawVal.icon)
                  .foregroundColor(Color.accentColor)
                  .font(.system(size: 17, weight: .bold))
              }
            }
          }
        }
      } label: {
        Image(systemName: sort.rawVal.icon)
          .foregroundColor(Color.accentColor)
          .fontSize(17, .bold)
      }
      
      if let data = subreddit.data {
        Button {
          routerProxy.router.path.append(SubViewType.info(subreddit))
        } label: {
          SubredditIcon(data: data)
        }
      }
    }
    .animation(nil, value: sort)
  }
}
