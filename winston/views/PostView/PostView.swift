//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import AVFoundation
import AlertToast
struct PostViewPayload: Hashable {
  let post: Post
  var postSelfAttr: AttributedString? = nil
  let sub: Subreddit
  var highlightID: String? = nil
}

struct PostView: View, Equatable {
  static func == (lhs: PostView, rhs: PostView) -> Bool {
    lhs.post.id == rhs.post.id && lhs.subreddit.id == rhs.subreddit.id
  }
  
  var post: Post
  var selfAttr: AttributedString? = nil
  var subreddit: Subreddit
  var highlightID: String?
  var forceCollapse: Bool = false
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @State private var ignoreSpecificComment = false
  @State private var sort: CommentSortOption = Defaults[.preferredCommentSort]
//  @State private var sort: CommentSortOption = .confidence
  @EnvironmentObject private var redditAPI: RedditAPI
  @EnvironmentObject private var routerProxy: RouterProxy
  @State var update = false

  func asyncFetch(_ full: Bool = true) async {
    if full {
        update.toggle()
    }
    if let result = await post.refreshPost(commentID: ignoreSpecificComment ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task {
        await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
      }
    }
  }
  
  func updateComments() {
    Task { await asyncFetch(true) }
  }
  
  var body: some View {
    let commentsHPad = selectedTheme.comments.theme.type == .card ? selectedTheme.comments.theme.outerHPadding : selectedTheme.comments.theme.innerPadding.horizontal
    ScrollViewReader { proxy in
      List {
        Group {
          Section {
            PostContent(post: post, selfAttr: selfAttr, sub: subreddit, forceCollapse: forceCollapse)
//              .equatable()
            
            Text("Comments")
              .fontSize(20, .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .id("comments-header")
              .listRowInsets(EdgeInsets(top: selectedTheme.posts.commentsDistance / 2, leading:commentsHPad, bottom: 8, trailing: commentsHPad))
          }
          .listRowBackground(Color.clear)
          
          PostReplies(update: update, post: post, subreddit: subreddit, ignoreSpecificComment: ignoreSpecificComment, highlightID: highlightID, sort: sort, proxy: proxy)
          
          if !ignoreSpecificComment && highlightID != nil {
            Section {
              Button {
                TempGlobalState.shared.globalLoader.enable("Loading full post...")
                withAnimation {
                  ignoreSpecificComment = true
                }
              } label: {
                HStack {
                  Image(systemName: "arrow.up.left.and.arrow.down.right")
                  Text("View full conversation")
                }
              }
            }
          }
          
          Section {
            Spacer()
              .frame(maxWidth: .infinity, minHeight: 72)
              .listRowBackground(Color.clear)
              .id("end-spacer")
          }
        }
        .listRowSeparator(.hidden)
      }
      .themedListBG(selectedTheme.posts.bg)
      .scrollContentBackground(.hidden)
      .transition(.opacity)
      .environment(\.defaultMinListRowHeight, 1)
      .listStyle(.plain)
      .refreshable {
        await asyncFetch(true)
      }
      .overlay(
        PostFloatingPill(post: post, subreddit: subreddit)
        , alignment: .bottomTrailing)
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

            if let data = subreddit.data, !feedsAndSuch.contains(subreddit.id) {
              Button {
                routerProxy.router.path.append(SubViewType.info(subreddit))
              } label: {
                SubredditIcon(data: data)
              }
            }
          }
          .animation(nil, value: sort)
      )
      .onChange(of: sort) { val in
        updateComments()
      }
      .onAppear {
        Task(priority: .background) {
          if subreddit.data == nil && subreddit.id != "home" {
            await subreddit.refreshSubreddit()
          }
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
