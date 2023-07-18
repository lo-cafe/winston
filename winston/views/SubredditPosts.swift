//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import Kingfisher

struct SubredditPosts: View {
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @ObservedObject var subreddit: Subreddit
  @Environment(\.openURL) var openURL
  @State var loading = true
  @State var loadingMore = false
  @StateObject var posts = ObservableArray<Post>()
  @State var lastPostAfter: String?
  @State var searchText: String = ""
  @State var sort: SubListingSortOption = Defaults[.preferredSort]
  //  @State var disableScroll = false
  @EnvironmentObject var redditAPI: RedditAPI
  
  func asyncFetch(loadMore: Bool = false) async {
    if subreddit.data == nil && subreddit.id != "home" {
      await subreddit.refreshSubreddit()
    }
    if posts.data.count > 0 && lastPostAfter == nil {
      return
    }
    if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil), let newPosts = result.0 {
      withAnimation {
        if loadMore {
          posts.data = (posts.data) + newPosts
        } else {
          posts.data = newPosts
        }
        loading = false
      }
      await redditAPI.updateAvatarURLCacheFromPosts(posts: newPosts)
      lastPostAfter = result.1
      loadingMore = false
    }
  }
  
  func fetch(loadMore: Bool = false) {
    if loadMore {
      loadingMore = true
    }
    Task {
      await asyncFetch(loadMore: loadMore)
    }
  }
  
  var body: some View {
    
    List {
      Group {
        if loading && posts.data.count == 0 {
          ProgressView()
            .frame(maxWidth: .infinity, minHeight: 500)
        } else {
          ForEach(Array(posts.data.enumerated()), id: \.self.element.id) { i, post in
            PostLink(post: post, sub: subreddit)
              .if(Int(Double(posts.data.count) * 0.75) == i) { view in
                view.onAppear {
                  fetch(loadMore: true)
                }
              }
          }
        }
      }
      .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
      .listRowSeparator(preferenceShowPostsCards ? .hidden : .automatic)
      .listRowBackground(Color.clear)
    }
    .listStyle(.plain)
    .overlay(
      Button {
        
      } label: {
        Image(systemName: "newspaper.fill")
          .fontSize(22, .bold)
          .frame(width: 64, height: 64)
          .foregroundColor(.blue)
          .floating()
          .contentShape(Circle())
      }
        .shrinkOnTap()
        .padding(.all, 12)
      , alignment: .bottomTrailing
    )
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
                    .foregroundColor(.blue)
                    .fontSize(17, .bold)
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
            NavigationLink {
              SubredditInfo(subreddit: subreddit)
            } label: {
              SubredditIcon(data: data)
            }
          }
        }
        .animation(nil, value: sort)
    )
    .navigationTitle("\(subreddit.id == "home" ? "Home" : "r/\(subreddit.data?.display_name ?? subreddit.id)")")
    .refreshable {
      await asyncFetch()
    }
    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .onAppear {
      //      sort = Defaults[.preferredSort]
      doThisAfter(0) {
        if posts.data.count == 0 {
          fetch()
        }
      }
    }
    //    .onChange(of: lightBoxType.url) { val in
    //      if val == nil {
    //        disableScroll = false
    //      }
    //    }
    //    .onChange(of: posts) { _ in
    //      print("posts")
    //    }
    .onChange(of: sort) { val in
      withAnimation {
        loading = true
        posts.data.removeAll()
      }
      fetch()
    }
    //    .onChange(of: vScrollWrapper.offset) { val in
    //          //      print(val, contentHeight)
    //          if val > contentHeight * 0.75 && !loading && !loadingMore {
    //            fetch(loadMore: true)
    //          }
    //        }
  }
}
