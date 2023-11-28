//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import CoreData

enum SubViewType: Hashable {
  case posts(Subreddit)
  case info(Subreddit)
}

struct SubredditPosts: View, Equatable {
  static func == (lhs: SubredditPosts, rhs: SubredditPosts) -> Bool {
    lhs.subreddit == rhs.subreddit
  }
  
  @ObservedObject var redditAPI = RedditAPI.shared
  @ObservedObject var subreddit: Subreddit
  @Default(.filteredSubreddits) private var filteredSubreddits
  @State private var loading = true
  @StateObject private var posts = NonObservableArray<Post>()
  @State private var loadedPosts: Set<String> = []
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption
  @State private var newPost = false
  
  @State private var savedMixedMediaLinks: [Either<Post, Comment>]?
  @State private var loadNextSavedData: Bool = false
  @State private var isSavedSubreddit: Bool = false
  @State private var hasViewLoaded: Bool = false
  @State private var reachedEndOfFeed: Bool = false
  
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @Environment(\.contentWidth) private var contentWidth
  
  let context = PersistenceController.shared.container.newBackgroundContext()
  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
  
  init(subreddit: Subreddit) {
    self.subreddit = subreddit;
    _sort = State(initialValue: Defaults[.perSubredditSort] ? (Defaults[.subredditSorts][subreddit.id] ?? Defaults[.preferredSort]) : Defaults[.preferredSort]);
  }
  
  var isFeedsAndSuch: Bool { feedsAndSuch.contains(subreddit.id) }
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false, searchText: String? = nil) async throws {
    if (subreddit.data == nil || force) && !isFeedsAndSuch {
      await subreddit.refreshSubreddit()
    }
    if posts.data.count > 0 && lastPostAfter == nil && !force {
      reachedEndOfFeed = true
      return
    }
    withAnimation {
      loading = true
    }
    
    if subreddit.id != "saved" {
      if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil, searchText: searchText, contentWidth: contentWidth), let newPosts = result.0 {
        await RedditAPI.shared.updatePostsWithAvatar(posts: newPosts, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size)
        withAnimation {
          let newPostsFiltered = newPosts.filter { !loadedPosts.contains($0.id) && !filteredSubreddits.contains($0.data?.subreddit ?? "") }
          
          if loadMore {
            posts.data.append(contentsOf: newPostsFiltered)
          } else {
            posts.data = newPostsFiltered
          }
          
          newPostsFiltered.forEach { loadedPosts.insert($0.id) }
          
          loading = false
          lastPostAfter = result.1
          reachedEndOfFeed = newPostsFiltered.count == 0
        }
      }
    } else {
      if let result = await subreddit.fetchSavedMixedMedia(after: loadMore ? lastPostAfter : nil, searchText: searchText, contentWidth: contentWidth) {
        withAnimation {
          if loadMore {
            savedMixedMediaLinks?.append(contentsOf: result)
          } else {
            savedMixedMediaLinks = result
          }
          
          loading = false
          if let lastItem = result.last {
            lastPostAfter = getItemId(for: lastItem)
          }
        }
        
        reachedEndOfFeed = result.count == 0
      }
    }
  }
  
  func fetch(_ loadMore: Bool = false, _ searchText: String? = nil) {
    Task(priority: .background) {
      do {
        try await asyncFetch(loadMore: loadMore, searchText: searchText)
      } catch {
        print(error)
      }
    }
  }
  
  func clearAndLoadData(withSearchText searchText: String? = nil) {
    withAnimation {
      posts.data.removeAll()
      loadedPosts.removeAll()
      reachedEndOfFeed = false
      
      if isSavedSubreddit {
        savedMixedMediaLinks?.removeAll()
      }
    }
    
    if let searchText = searchText, !searchText.isEmpty {
      fetch(false, searchText)
    } else {
      fetch()
    }
  }
  
  func updatePostsCalcs(_ newTheme: WinstonTheme) {
    Task(priority: .background) { posts.data.forEach { $0.setupWinstonData(data: $0.data, winstonData: $0.winstonData, theme: newTheme, fetchAvatar: false) } }
  }
  
  var body: some View {
    Group {
      if !isSavedSubreddit {
        Group {
          if IPAD {
            SubredditPostsIPAD(showSub: isFeedsAndSuch, subreddit: subreddit, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme)
          } else {
            SubredditPostsIOS(showSub: isFeedsAndSuch, lastPostAfter: lastPostAfter, subreddit: subreddit, posts: posts.data, searchText: searchText, fetch: fetch, selectedTheme: selectedTheme, reachedEndOfFeed: $reachedEndOfFeed)
            
          }
        }
        .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
      } else {
        if let savedMixedMediaLinks = savedMixedMediaLinks, let user = redditAPI.me {
          MixedContentFeedView(mixedMediaLinks: savedMixedMediaLinks, loadNextData: $loadNextSavedData, user: user, reachedEndOfFeed: $reachedEndOfFeed)
            .onChange(of: loadNextSavedData) { shouldLoad in
              if shouldLoad {
                fetch(shouldLoad)
                loadNextSavedData = false
              }
            }
        }
      }
    }
    .onAppear {
      if !hasViewLoaded {
        isSavedSubreddit = subreddit.id == "saved" // detect unique saved subreddit (saved posts and comments require unique logic)
        hasViewLoaded = true
      }
    }
    .environment(\.defaultMinListRowHeight, 1)
    .loader(loading && posts.data.count == 0)
    .overlay(
      isFeedsAndSuch
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
    //    .sheet(isPresented: $newPost, content: {
    //      NewPostModal(subreddit: subreddit)
    //    })
    .navigationBarItems(trailing: SubredditPostsNavBtns(sort: $sort, subreddit: subreddit, routerProxy: routerProxy))
    .onSubmit(of: .search) {
      clearAndLoadData(withSearchText: searchText)
    }
    .refreshable {
      clearAndLoadData()
    }
    .navigationTitle("\(isFeedsAndSuch ? subreddit.id.capitalized : "r/\(subreddit.data?.display_name ?? subreddit.id)")")
    .task(priority: .background) {
      if posts.data.count == 0 && (savedMixedMediaLinks?.count == 0 || savedMixedMediaLinks == nil) {
        do {
          try await asyncFetch()
        } catch {
          print(error)
        }
      }
    }
    .onChange(of: sort) { val in
      clearAndLoadData()
    }
    .onChange(of: cs) { _ in
      updatePostsCalcs(selectedTheme)
    }
    .onChange(of: selectedTheme, perform: updatePostsCalcs)
    .onChange(of: searchText) { val in
      if searchText.isEmpty {
        clearAndLoadData()
      }
    }
  }
  
}


struct SubredditPostsNavBtns: View, Equatable {
  static func == (lhs: SubredditPostsNavBtns, rhs: SubredditPostsNavBtns) -> Bool {
    lhs.sort == rhs.sort && (lhs.subreddit.data == nil) == (rhs.subreddit.data == nil)
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
                  Defaults[.subredditSorts][subreddit.id] = .top(topOpt)
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
              Defaults[.subredditSorts][subreddit.id] = opt
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
      .disabled(subreddit.id == "saved")
      
      if let data = subreddit.data {
        Button {
          routerProxy.router.path.append(SubViewType.info(subreddit))
        } label: {
          SubredditIcon(subredditIconKit: data.subredditIconKit)
        }
      }
    }
    .animation(nil, value: sort)
  }
}
