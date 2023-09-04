//
//  MultiPostsView.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import WaterfallGrid

enum MultiViewType: Hashable {
  case posts(Multi)
  case info(Multi)
}

struct MultiPostsView: View {
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @ObservedObject var multi: Multi
  @State private var loading = true
  @State private var posts: [Post] = []
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption = Defaults[.preferredSort]
  @State private var newPost = false
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
  @EnvironmentObject private var routerProxy: RouterProxy
  
  func asyncFetch(force: Bool = false, loadMore: Bool = false) async {
    //    if (multi.data == nil || force) {
    //      await multi.refreshSubreddit()
    //    }
    if posts.count > 0 && lastPostAfter == nil && !force {
      return
    }
    if let result = await multi.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil), let newPosts = result.0 {
      withAnimation {
        if loadMore {
          posts.append(contentsOf: newPosts)
        } else {
          posts = newPosts
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
    List {
      Section {
        ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in
          
          PostLinkNoSub(showSub: true, post: post)
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
            .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
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
    .loader(loading && posts.count == 0)
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
      }
      fetch()
      Defaults[.preferredSort] = sort
    }
//    .searchable(text: $searchText, prompt: "Search r/\(subreddit.data?.display_name ?? subreddit.id)")
    .refreshable { await asyncFetch(force: true) }
    .navigationTitle(multi.data?.name ?? "MultiZ")
    .background(.thinMaterial)
  }
  
}
