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

struct PostView: View, Equatable {
  static func == (lhs: PostView, rhs: PostView) -> Bool {
    lhs.post == rhs.post && lhs.subreddit.id == rhs.subreddit.id && lhs.hideElements == rhs.hideElements && lhs.ignoreSpecificComment == rhs.ignoreSpecificComment && lhs.sort == rhs.sort && lhs.update == rhs.update
  }
  
  @ObservedObject var post: Post
  var subreddit: Subreddit
  var forceCollapse: Bool
  var highlightID: String?
  @Default(.PostPageDefSettings) private var defSettings
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.globalLoaderStart) private var globalLoaderStart
  @State private var ignoreSpecificComment = false
  @State private var hideElements = true
  @State private var sort: CommentSortOption
  @State private var update = false
	 
  init(post: Post, subreddit: Subreddit, forceCollapse: Bool = false, highlightID: String? = nil) {
    self.post = post
    self.subreddit = subreddit
    self.forceCollapse = forceCollapse
    self.highlightID = highlightID
    
    let defSettings = Defaults[.PostPageDefSettings]
    let commentsDefSettings = Defaults[.CommentsSectionDefSettings]
    
    if self.post.data == nil {
			print("post.data is nil")
			updatePost()
		}
    
    _sort = State(initialValue: defSettings.perPostSort ? (defSettings.postSorts[post.id] ?? commentsDefSettings.preferredSort) : commentsDefSettings.preferredSort);
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
              PostFloatingPill(post: post, subreddit: subreddit, showUpVoteRatio: defSettings.showUpVoteRatio)
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
                globalLoaderStart("Loading full post...")
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
      .transition(.opacity)
      .environment(\.defaultMinListRowHeight, 1)
      .listStyle(.plain)
      .refreshable {
        withAnimation { update.toggle() }
        await asyncFetch(true)
      }
      .overlay(alignment: .bottomTrailing) {
        if !selectedTheme.posts.inlineFloatingPill {
          PostFloatingPill(post: post, subreddit: subreddit, showUpVoteRatio: defSettings.showUpVoteRatio)
        }
      }
      .navigationBarTitle("\(post.data?.num_comments ?? 0) comments", displayMode: .inline)
      .toolbar { Toolbar(hideElements: hideElements, subreddit: subreddit, post: post, sort: $sort) }
      .onChange(of: sort) { val in
        updatePost()
      }
//      .onChange(of: cs) { _ in
//        Task(priority: .background) {
//          post.setupWinstonData(data: post.data, winstonData: post.winstonData, theme: selectedTheme, fetchAvatar: false)
//        }
//      }
      .onAppear {
        doThisAfter(0.5) {
          print("maos", hideElements)
          hideElements = false
          print("maoso", hideElements)
        }
        if post.data == nil {
          updatePost()
        }
        
        Task(priority: .background) {          
          if let numComments = post.data?.num_comments {
            await post.saveCommentsCount(numComments: numComments)
          }
        }
        
        Task(priority: .background) {
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
              Defaults[.PostPageDefSettings].postSorts[post.id] = opt
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
