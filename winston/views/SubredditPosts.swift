//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import WaterfallGrid

enum SubViewType: Hashable {
  case posts(Subreddit)
  case info(Subreddit)
}

struct SubredditPosts: View {
  @Default(.filteredSubreddits) private var filteredSubreddits
  @ObservedObject var subreddit: Subreddit
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
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false, searchText: String? = nil) async {
    if (subreddit.data == nil || force) && !feedsAndSuch.contains(subreddit.id) {
      await subreddit.refreshSubreddit()
    }
    if posts.data.count > 0 && lastPostAfter == nil && !force {
      return
    }
    if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil, searchText: searchText), let newPosts = result.0 {
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
        await RedditAPI.shared.updateAvatarURLCacheFromPosts(posts: newPosts)
      }
    }
  }
  
  func fetch(loadMore: Bool = false, searchText: String? = nil) {
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
      fetch(searchText: searchText)
    } else {
      fetch()
    }
    
    //    Defaults[.preferredSort] = sort
  }
  
  var body: some View {
    //      if IPAD {
    //        ScrollView(.vertical) {
    //          WaterfallGrid(posts, id: \.self.id) { el in
    //            PostLink(post: el, sub: subreddit)
    //          }
    //          .gridStyle(columns: 2, spacing: 16, animation: .easeInOut(duration: 0.5))
    //          .scrollOptions(direction: .vertical)
    //          .padding(.horizontal, 16)
    //        }
    //        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
    //          scrollView.backgroundColor = UIColor.systemGroupedBackground
    //        }
    //      } else {
    List {
      
      
      Section {
        if posts.data.count == 0 { Color.clear }
        
        ForEach(Array(posts.data.enumerated()), id: \.self.element.id) { i, post in
          
          PostLink(post: post, sub: subreddit)
//            .equatable()
            .onAppear {
              if(Int(Double(posts.data.count) * 0.75) == i) {
                if !searchText.isEmpty {
                  fetch(loadMore: true, searchText: searchText)
                } else {
                  fetch(loadMore: true)
                }
              }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .animation(.default, value: posts.data)
          
          if selectedTheme.postLinks.divider.style != .no && i != (posts.data.count - 1) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
              .id("\(post.id)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
          
        }
        if !lastPostAfter.isNil {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: posts.data.count > 0 ? 100 : UIScreen.screenHeight - 200 )
            .id("post-loading")
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
    }
    .themedListBG(selectedTheme.postLinks.bg)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 1)
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
          .foregroundColor(.blue)
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
    .navigationBarItems(
      trailing:
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
                          .foregroundColor(.blue)
                          .font(.system(size: 17, weight: .bold))
                      }
                    }
                  }
                } label: {
                  Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                    .foregroundColor(.blue)
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
                      .foregroundColor(.blue)
                      .font(.system(size: 17, weight: .bold))
                  }
                }
              }
            }
          } label: {
            Button { } label: {
              Image(systemName: sort.rawVal.icon)
                .foregroundColor(.blue)
                .fontSize(17, .bold)
            }
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
    )
    .onAppear {
      if posts.data.count == 0 {
        doThisAfter(0) {
          fetch()
        }
      }
    }
    .onChange(of: sort) { val in
      clearAndLoadData()
    }
    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .onSubmit(of: .search) {
      clearAndLoadData(withSearchText: searchText)
    }
    .onChange(of: searchText) { val in
      if searchText.isEmpty {
        clearAndLoadData()
      }
    }
    .refreshable {
      loadedPosts.removeAll()
      await asyncFetch(force: true)
    }
    .navigationTitle("\(feedsAndSuch.contains(subreddit.id) ? subreddit.id.capitalized : "r/\(subreddit.data?.display_name ?? subreddit.id)")")
  }
  
}
