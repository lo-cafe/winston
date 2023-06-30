//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import SwiftUI
import Defaults
import CachedAsyncImage
import SwiftUIIntrospect

struct SubredditPosts: View {
  var subreddit: Subreddit
  @Environment(\.openURL) var openURL
  @State var loading = true
  @State var loadingMore = false
  @State var posts: [Post] = []
  @State var lastPostAfter: String?
  @State var scrollPos: CGFloat = 0
  @State var smallerPostHeight: CGFloat = 0
  @State var biggerPostHeight: CGFloat = 0
  @State var sort: SubListingSortOption = Defaults[.preferredSort]
  @State var scrollViewHeight: CGFloat = .zero
  @State var disableScroll = false
  @EnvironmentObject var redditAPI: RedditAPI
  //  @EnvironmentObject var lightBoxType: ContentLightBox
  
  var contentHeight: CGFloat {
    (((UIScreen.screenHeight / 1.15) / 2.5)) * CGFloat(posts.count)
  }
  
  func asyncFetch(loadMore: Bool = false) async {
    if let result = await subreddit.fetchPosts(sort: sort, after: loadMore ? lastPostAfter : nil), let newPosts = result.0 {
      withAnimation {
        if loadMore {
          posts = posts + newPosts
        } else {
          posts = newPosts
        }
        loading = false
      }
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
    ObservedScrollView(offset: $scrollPos) {
      LazyVStack(spacing: 12) {
        if loading {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: 700 )
        } else {
          
          Group {
//            ForEach(posts) { post in
//              let data = post.data
//              PostLink(data: data, sub: subreddit, disableScroll: $disableScroll)
//                .background(
//                  GeometryReader { geo in
//                    Color.clear
//                      .onAppear {
//                        let height = geo.size.height
//                        if height != 0 {
//                          if smallerPostHeight == 0 || height < smallerPostHeight {
//                            smallerPostHeight = height
//                          }
//                          if biggerPostHeight == 0 || height > biggerPostHeight {
//                            biggerPostHeight = height
//                          }
//                        }
//                      }
//                  }
//                )
//            }
          }
          
        }
      }
      .padding(.horizontal, 8)
      .padding(.top, 8)
    }
    //    .scrollDisabled(disableScroll)
    //    .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
    //      scrollView.isScrollEnabled = !disableScroll
    //    }
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
            Button { } label: {
              let communityIcon = data.community_icon.split(separator: "?")
              let icon = data.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : data.icon_img
              CachedAsyncImage(url: URL(string: icon)) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 30, height: 30)
                  .mask(Circle())
              } placeholder: {
                Text(data.display_name.prefix(1).uppercased())
                  .frame(width: 30, height: 30)
                  .background(.blue, in: Circle())
                  .mask(Circle())
                  .fontWeight(.semibold)
              }
            }
          }
        }
        .animation(nil, value: sort)
    )
    .navigationTitle("r/\(subreddit.data?.display_name ?? "error")")
    .refreshable {
      await asyncFetch()
    }
    .onAppear {
      fetch()
    }
    //    .onChange(of: lightBoxType.url) { val in
    //      if val == nil {
    //        disableScroll = false
    //      }
    //    }
    .onChange(of: sort) { val in
      withAnimation {
        loading = true
      }
      fetch()
    }
    .onChange(of: scrollPos) { val in
      //      print(val, contentHeight)
      if val > contentHeight * 0.75 && !loading && !loadingMore {
        fetch(loadMore: true)
      }
    }
  }
}
