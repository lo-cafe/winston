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
    lhs.post == rhs.post && lhs.subreddit.id == rhs.subreddit.id && lhs.hideElements == rhs.hideElements && lhs.ignoreSpecificComment == rhs.ignoreSpecificComment && lhs.sort == rhs.sort && lhs.update == rhs.update && lhs.comments.count == rhs.comments.count
  }
  
  var post: Post
  var subreddit: Subreddit
  var forceCollapse: Bool
  var highlightID: String?
  @Default(.PostPageDefSettings) private var defSettings
  @Default(.CommentsSectionDefSettings) var commentsSectionDefSettings
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.globalLoaderStart) private var globalLoaderStart
  @State private var ignoreSpecificComment = false
  @State private var hideElements = true
  @State private var sort: CommentSortOption
  @State private var update = false
  
  @SilentState private var topVisibleCommentId: String? = nil
  @SilentState private var previousScrollTarget: String? = nil
  @State private var comments: [Comment] = []
  
  init(post: Post, subreddit: Subreddit, forceCollapse: Bool = false, highlightID: String? = nil) {
    self.post = post
    self.subreddit = subreddit
    self.forceCollapse = forceCollapse
    self.highlightID = highlightID
    
    let defSettings = Defaults[.PostPageDefSettings]
    let commentsDefSettings = Defaults[.CommentsSectionDefSettings]
    
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
    let navtitle: String = post.data?.title ?? "no title"
    let subnavtitle: String = "r/\(post.data?.subreddit ?? "no sub") \u{2022} " + String(localized:"\(post.data?.num_comments ?? 0) comments")
    let commentsHPad = selectedTheme.comments.theme.outerHPadding > 0 ? selectedTheme.comments.theme.outerHPadding : selectedTheme.comments.theme.innerPadding.horizontal
    GeometryReader { geometryReader in
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
              PostReplies(update: update, post: post, subreddit: subreddit, ignoreSpecificComment: ignoreSpecificComment, highlightID: highlightID, sort: sort, proxy: proxy, geometryReader: geometryReader, topVisibleCommentId: $topVisibleCommentId, previousScrollTarget: $previousScrollTarget, comments: $comments)
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
        .navigationBarTitle("\(navtitle)", displayMode: .inline)
        .toolbar { Toolbar(title: navtitle, subtitle: subnavtitle, hideElements: hideElements, subreddit: subreddit, post: post, sort: $sort) }
        .onChange(of: sort) { val in
          updatePost()
        }
        .onAppear {
          doThisAfter(0.5) {
            hideElements = false
            doThisAfter(0.1) {
              if highlightID != nil { withAnimation { proxy.scrollTo("loading-comments") } }
            }
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
        .onPreferenceChange(CommentUtils.AnchorsKey.self) { anchors in
          Task(priority: .background) {
            topVisibleCommentId = CommentUtils.shared.topCommentRow(of: anchors, in: geometryReader)
          }
        }
        .commentSkipper(
          showJumpToNextCommentButton: $commentsSectionDefSettings.commentSkipper,
          topVisibleCommentId: $topVisibleCommentId,
          previousScrollTarget: $previousScrollTarget,
          comments: comments,
          reader: proxy
        )
      }
    }
  }
}

private struct Toolbar: ToolbarContent {
  var title: String
  var subtitle: String
  var hideElements: Bool
  var subreddit: Subreddit
  var post: Post
  @Binding var sort: CommentSortOption
  
  var body: some ToolbarContent {
    if !IPAD {
      ToolbarItem(id: "postview-title", placement: .principal) {
        VStack {
          Text(title)
            .font(.headline)
          Text(subtitle)
            .font(.subheadline)
        }
      }
    }
    
    ToolbarItem(id: "postview-sortandsub", placement: .navigationBarTrailing) {
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
}
