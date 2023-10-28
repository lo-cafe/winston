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
  
  @ObservedObject var post: Post
  @ObservedObject private var cachesPostsAttrStr = Caches.postsAttrStr
  var selfAttr: AttributedString? = nil
  var subreddit: Subreddit
  var highlightID: String?
  var forceCollapse: Bool = false
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @State private var ignoreSpecificComment = false
  @State private var hideElements = true
  @State private var sort: CommentSortOption = Defaults[.preferredCommentSort]
  //  @State private var sort: CommentSortOption = .confidence
  
  @EnvironmentObject private var routerProxy: RouterProxy
  @State var update = false
  
  func asyncFetch(_ full: Bool = true) async {
    if full {
      update.toggle()
    }
    if let result = await post.refreshPost(commentID: ignoreSpecificComment ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task(priority: .background) {
        await RedditAPI.shared.updateAvatarURLCacheFromComments(comments: newComments, avatarSize: selectedTheme.comments.theme.badge.avatar.size)
      }
    }
  }
  
  func updatePost() {
    Task(priority: .background) { await asyncFetch(true) }
  }
  
  var body: some View {
    let commentsHPad = selectedTheme.comments.theme.outerHPadding > 0 ? selectedTheme.comments.theme.outerHPadding : selectedTheme.comments.theme.innerPadding.horizontal
    ScrollViewReader { proxy in
      List {
        Group {
          Section {
            PostContent(post: post, selfAttr: cachesPostsAttrStr.cache[post.id]?.data ?? selfAttr, sub: subreddit, forceCollapse: forceCollapse)
            //              .equatable()
            
            Text("Comments")
              .fontSize(20, .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .id("comments-header")
              .listRowInsets(EdgeInsets(top: selectedTheme.posts.commentsDistance / 2, leading:commentsHPad, bottom: 8, trailing: commentsHPad))
          }
          .listRowBackground(Color.clear)
          
          if !hideElements {
            PostReplies(update: update, post: post, subreddit: subreddit, ignoreSpecificComment: ignoreSpecificComment, highlightID: highlightID, sort: sort, proxy: proxy)
          }
          
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
            .listRowBackground(Color.primary.opacity(0.1))
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
      .scrollIndicators(.never)
      .themedListBG(selectedTheme.posts.bg)
      .scrollContentBackground(.hidden)
      .transition(.opacity)
      .environment(\.defaultMinListRowHeight, 1)
      .listStyle(.plain)
      .refreshable {
        withAnimation { update.toggle() }
        await asyncFetch(true)
      }
      .overlay(
        PostFloatingPill(post: post, subreddit: subreddit)
        , alignment: .bottomTrailing
      )
      .navigationBarTitle("\(post.data?.num_comments ?? 0) comments", displayMode: .inline)
      .toolbar { Toolbar(hideElements: hideElements, subreddit: subreddit, routerProxy: routerProxy, sort: $sort) }
      .onChange(of: sort) { val in
        updatePost()
      }
      .onAppear {
        if post.data == nil {
          updatePost()
        }
        Task(priority: .background) {
          doThisAfter(0.5) {
            hideElements = false
          }
          if subreddit.data == nil && subreddit.id != "home" {
            await subreddit.refreshSubreddit()
          }
        }
      }
    }
    
  }
}

private struct Toolbar: View {
  var hideElements: Bool
  var subreddit: Subreddit
  var routerProxy: RouterProxy
  @Binding var sort: CommentSortOption
  var body: some View {
    HStack {
      Menu {
        if !hideElements {
          ForEach(CommentSortOption.allCases) { opt in
            Button {
              sort = opt
            } label: {
              HStack {
                Text(opt.rawVal.value.capitalized)
                Spacer()
                Image(systemName: opt.rawVal.icon)
                  .foregroundColor(Color.accentColor)
                  .fontSize(17, .bold)
              }
            }
          }
        }
      } label: {
        Image(systemName: sort.rawVal.icon)
          .foregroundColor(Color.accentColor)
          .fontSize(17, .bold)
      }
      
      if let data = subreddit.data, !feedsAndSuch.contains(subreddit.id) {
        SubredditIcon(data: data)
          .onTapGesture { routerProxy.router.path.append(SubViewType.info(subreddit)) }
      }
    }
    .animation(nil, value: sort)
  }
}
