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
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @ObservedObject var subreddit: Subreddit
  @Environment(\.openURL) private var openURL
  @State private var loading = true
  @State private var posts: [Post] = []
  @State private var loadedPosts: Set<String> = []
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption = Defaults[.preferredSort]
  @State private var newPost = false
  @EnvironmentObject private var redditAPI: RedditAPI
  @EnvironmentObject private var router: Router
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false) async {
    if (subreddit.data == nil || force) && !feedsAndSuch.contains(subreddit.id) {
      await subreddit.refreshSubreddit()
    }
    if posts.count > 0 && lastPostAfter == nil && !force {
      return
    }
    if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil), let newPosts = result.0 {
      withAnimation {
        if loadMore {
          let newPostsFiltered = newPosts.filter { !loadedPosts.contains($0.id) }
          posts.append(contentsOf: newPostsFiltered)
          newPostsFiltered.forEach { loadedPosts.insert($0.id) }
        } else {
          let newPostsFiltered = newPosts.filter { !loadedPosts.contains($0.id) }
          posts = newPostsFiltered
          newPostsFiltered.forEach { loadedPosts.insert($0.id) }
        }
        loading = false
        lastPostAfter = result.1
      }
      Task(priority: .background) {
        await redditAPI.updateAvatarURLCacheFromPosts(posts: newPosts)
      }
    }
  }
  
  func fetch(loadMore: Bool = false) {
    Task(priority: .background) {
      await asyncFetch(loadMore: loadMore)
    }
  }
  
  var body: some View {
    Group {
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
          ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in

            PostLink(post: post, sub: subreddit)
              .equatable()
              .onAppear { if(Int(Double(posts.count) * 0.75) == i) { fetch(loadMore: true) } }
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
              .animation(.default, value: posts)

            if !preferenceShowPostsCards && i != (posts.count - 1) {
              VStack(spacing: 0) {
                Divider()
                Color.listBG
                  .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6)
                Divider()
              }
              .id("\(post.id)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

          }
          if !lastPostAfter.isNil {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: posts.count > 0 ? 100 : UIScreen.screenHeight - 200 )
              .id("post-loading")
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .background(Color(UIColor.systemGroupedBackground))
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      .environment(\.defaultMinListRowHeight, 1)
    }
    .loader(loading && posts.count == 0)
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
            Button {
              router.path.append(SubViewType.info(subreddit))
            } label: {
              SubredditIcon(data: data)
            }
          }
        }
        .animation(nil, value: sort)
    )
    .onAppear {
      //      sort = Defaults[.preferredSort]
      if posts.count == 0 {
        doThisAfter(0) {
          fetch()
        }
      }
    }
    .onChange(of: sort) { val in
      withAnimation {
        loading = true
        posts.removeAll()
        loadedPosts.removeAll()
      }
      fetch()
      Defaults[.preferredSort] = sort
    }
    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .refreshable {
      loadedPosts.removeAll()
      await asyncFetch(force: true)
    }
    .navigationTitle("\(feedsAndSuch.contains(subreddit.id) ? subreddit.id.capitalized : "r/\(subreddit.data?.display_name ?? subreddit.id)")")
    .background(.thinMaterial)
  }
  
}
