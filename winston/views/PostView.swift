//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Defaults
import VideoPlayer
import CoreMedia
import Defaults
import ASCollectionView

struct PostView: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  @State var loading = true
  @State var disableScroll = false
  @State var loadingMore = false
  @State var sort: CommentSortOption = Defaults[.preferredCommentSort]
  @StateObject var comments = ObservableArray<Comment>()
  @State var lastPostAfter: String?
  @State var avatars: [String:String]?
  @EnvironmentObject var redditAPI: RedditAPI
  
  func asyncFetch(_ loadMore: Bool = false, _ full: Bool = true) async {
        if let result = await post.refreshPost(sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
          await MainActor.run {
            withAnimation {
              if loadMore {
                comments.data = (comments.data) + newComments
              } else {
                comments.data = newComments
              }
              loading = false
            }
            lastPostAfter = result.1
            loadingMore = false
          }
          await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
        } else {
          await MainActor.run {
            withAnimation {
              loading = false
            }
          }
        }
  }
  
  func fetch(loadMore: Bool = false, full: Bool = true) {
        if loadMore {
          loadingMore = true
        }
        Task {
          await asyncFetch(loadMore, full)
        }
  }
  
  var body: some View {
    List {
      Group {
        if let data = post.data {
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
              Text(data.title)
                .fontSize(20, .semibold)

              let imgPost = data.url.hasSuffix("jpg") || data.url.hasSuffix("png")

              if let _ = data.secure_media {
                VideoPlayerPost(prefix: "postView", post: post)
              }

              if imgPost {
                ImageMediaPost(prefix: "postView", post: post)
              }

              if data.selftext != "" {
                Text(data.selftext.md())
                  .fontSize(15)
              }

              if let fullname = data.author_fullname {
                Badge(author: data.author, fullname: fullname, created: data.created)
              }
            }

            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)

            HStack(spacing: 0) {
              if let link_flair_text = data.link_flair_text {
                Rectangle()
                  .fill(.primary.opacity(0.1))
                  .frame(maxWidth: .infinity, maxHeight: 1)

                Text(link_flair_text)
                  .fontSize(13)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 2)
                  .background(Capsule(style: .continuous).fill(.secondary.opacity(0.25)))
                  .foregroundColor(.primary.opacity(0.5))
                  .fixedSize()
              }
              Rectangle()
                .fill(.primary.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: 1)
            }
            .padding(.horizontal, 2)
          }
        } else {
          VStack {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
          }
        }

        Text("Comments")
          .fontSize(20, .bold)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        let commentsData = comments.data
        if commentsData.count > 0 {
          ForEach(commentsData, id: \.self.id) { comment in
            if let postFullname = post.data?.name {
              VStack {
                CommentLink(disableScroll: $disableScroll, postFullname: postFullname, refresh: asyncFetch, comment: comment)
              }
              .listRowSeparator(preferenceShowCommentsCards ? .hidden : .automatic)
            }
          }
        } else {
          if loading {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: 300 )
          } else {
            Text("No comments around...")
              .frame(maxWidth: .infinity, minHeight: 300)
              .opacity(0.25)
          }
        }
        
        Spacer()
          .frame(maxWidth: .infinity, minHeight: 72)
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
    }
    .introspect(.scrollView, on: .iOS(.v15, .v16, .v17)) { scrollView in
      //      scrollView.disableScroll = disableScroll
      scrollView.isScrollEnabled = !disableScroll
    }
    //    .scrollDisabled(disableScroll)
    .listStyle(.plain)
    .refreshable {
      await asyncFetch(false, true)
    }
    .overlay(
      PostFloatingPill(post: post)
      , alignment: .bottomTrailing
    )
    //    .navigationBarTitle(Text(post.data == nil ? "loading..." : "\(post.data?.num_comments ?? 0) comments"), displayMode: .inline)
    .navigationBarTitle("\(post.data?.num_comments ?? 0) comments", displayMode: .inline)
    .navigationBarItems(
      trailing:
        HStack {
          Menu {
            ForEach(CommentSortOption.allCases) { opt in
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
              WebImage(url: URL(string: icon))
                .resizable()
                .placeholder {
                  Text(data.display_name.prefix(1).uppercased())
                    .frame(width: 30, height: 30)
                    .background(.blue, in: Circle())
                    .mask(Circle())
                    .fontSize(16, .semibold)
                }
                .scaledToFill()
                .frame(width: 30, height: 30)
                .mask(Circle())
            }
          }
        }
        .animation(nil, value: sort)
    )
    .onAppear {
      if comments.data.count == 0 || post.data == nil {
        fetch(full: post.data == nil)
      }
      if subreddit.data == nil {
        Task {
          await subreddit.refreshSubreddit()
        }
      }
    }
  }
}



//struct Post_Previews: PreviewProvider {
//    static var previews: some View {
//        PostLink()
//    }
//}
