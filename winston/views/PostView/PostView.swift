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

struct PostViewPayload: Hashable, Equatable, Codable {
  let post: Post
  let sub: Subreddit
  var highlightID: String? = nil
}

struct PostView: View, Equatable {
  static func == (lhs: PostView, rhs: PostView) -> Bool {
    lhs.post.id == rhs.post.id && lhs.subreddit.id == rhs.subreddit.id
  }
  
  @ObservedObject var post: Post
  var subreddit: Subreddit
  var highlightID: String?
  var forceCollapse: Bool = false
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @State private var ignoreSpecificComment = false
  @State private var hideElements = true
  @State private var sort: CommentSortOption = Defaults[.preferredCommentSort]
  //  @State private var sort: CommentSortOption = .confidence
  
  @State var update = false
    
  init(post: Post, subreddit: Subreddit) {
    self.post = post
    self.subreddit = subreddit
    
    _sort = State(initialValue: Defaults[.perPostSort] ? (Defaults[.postSorts][post.id] ?? Defaults[.preferredCommentSort]) : Defaults[.preferredCommentSort]);
  }
  
  init(post: Post, subreddit: Subreddit, forceCollapse: Bool) {
    self.post = post
    self.subreddit = subreddit
    self.forceCollapse = forceCollapse
    
    _sort = State(initialValue: Defaults[.perPostSort] ? (Defaults[.postSorts][post.id] ?? Defaults[.preferredCommentSort]) : Defaults[.preferredCommentSort]);
  }
  
  init(post: Post, subreddit: Subreddit, highlightID: String?) {
    self.post = post
    self.subreddit = subreddit
    self.highlightID = highlightID
    
    _sort = State(initialValue: Defaults[.perPostSort] ? (Defaults[.postSorts][post.id] ?? Defaults[.preferredCommentSort]) : Defaults[.preferredCommentSort]);
  }
  
  func asyncFetch(_ full: Bool = true) async {
    if full {
      update.toggle()
    }
    if let result = await post.refreshPost(commentID: ignoreSpecificComment ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task(priority: .background) {
        await RedditAPI.shared.updateCommentsWithAvatar(comments: newComments, avatarSize: selectedTheme.comments.theme.badge.avatar.size)
      }
      
      Task(priority: .background) {
        if let numComments = post.data?.num_comments {
          await post.saveCommentsCount(numComments: numComments)
        }
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
            if let winstonData = post.winstonData {
              PostContent(post: post, winstonData: winstonData, sub: subreddit, forceCollapse: forceCollapse)
            }
            //              .equatable()
            
            if selectedTheme.posts.inlineFloatingPill {
              PostFloatingPill(post: post, subreddit: subreddit)
                    .padding(-10)
            }
            
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
      .overlay(alignment: .bottomTrailing) {
        if !selectedTheme.posts.inlineFloatingPill {
          PostFloatingPill(post: post, subreddit: subreddit)
        }
      }
      .navigationBarTitle("\(post.data?.num_comments ?? 0) comments", displayMode: .inline)
      .toolbar { Toolbar(hideElements: hideElements, subreddit: subreddit, post: post, sort: $sort) }
      .onChange(of: sort) { val in
        updatePost()
      }
      .onChange(of: cs) { _ in
        Task(priority: .background) {
          post.setupWinstonData(data: post.data, winstonData: post.winstonData, theme: selectedTheme, fetchAvatar: false)
        }
      }
      .onAppear {
        if post.data == nil {
          updatePost()
        }
        
        Task(priority: .background) {          
          if let numComments = post.data?.num_comments {
            await post.saveCommentsCount(numComments: numComments)
          }
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
  var post: Post
  @Binding var sort: CommentSortOption
  var body: some View {
    HStack {
      Menu {
        if !hideElements {
          ForEach(CommentSortOption.allCases) { opt in
            Button {
              sort = opt
              Defaults[.postSorts][post.id] = opt
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
        SubredditIcon(subredditIconKit: data.subredditIconKit)
          .onTapGesture { Nav.to(.reddit(.subInfo(subreddit))) }
      }
    }
    .animation(nil, value: sort)
  }
}
