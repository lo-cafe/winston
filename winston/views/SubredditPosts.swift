//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import ASCollectionView
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
    if subreddit.data == nil {
      await subreddit.refreshSubreddit()
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
      ForEach(Array(posts.data.enumerated()), id: \.self.element.id) { i, post in
        PostLink(post: post, sub: subreddit)
          .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
          .listRowSeparator(preferenceShowPostsCards ? .hidden : .automatic)
          .listRowBackground(Color.clear)
          .if(Int(Double(posts.data.count) * 0.75) == i) { view in
            view.onAppear {
              fetch(loadMore: true)
            }
          }
      }
    }
//    .navigationDestination(for: Post.self) { post in
//      PostView(post: post, subreddit: subreddit)
//    }
//    .navigationDestination(for: String.self) { author in
//      UserView(user: User(id: author, api: redditAPI))
//    }
    .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
      scrollView.delaysContentTouches = false
      scrollView.panGestureRecognizer.delaysTouchesBegan = true
    }
    .listStyle(.plain)
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
              let communityIcon = data.community_icon.split(separator: "?")
              let icon = data.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : data.icon_img
              KFImage(URL(string: icon)!)
                .resizable()
//                .placeholder {
//                  Text(data.display_name.prefix(1).uppercased())
//                    .frame(width: 30, height: 30)
//                    .background(.blue, in: Circle())
//                    .mask(Circle())
//                    .fontSize(16, .semibold)
//                }
                .scaledToFill()
                .frame(width: 30, height: 30)
                .mask(Circle())
            }
          }
        }
        .animation(nil, value: sort)
    )
    .navigationTitle("r/\(subreddit.data?.display_name ?? subreddit.id)")
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
