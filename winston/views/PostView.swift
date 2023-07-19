//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import UIKit
import Kingfisher
import Defaults
import VideoPlayer
import CoreMedia
import Defaults
import MarkdownUI

struct PostContent: View {
  @ObservedObject var post: Post
  var body: some View {
    if let data = post.data {
      VStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 12) {
          Text(data.title)
            .fontSize(20, .semibold)
            .fixedSize(horizontal: false, vertical: true)
          
          let imgPost = data.url.hasSuffix("jpg") || data.url.hasSuffix("png")
          
          if let _ = data.secure_media {
            VideoPlayerPost(prefix: "postView", post: post)
          }
          
          if imgPost {
            ImageMediaPost(prefix: "postView", post: post)
          }
          
          if data.selftext != "" {
            MD(str: data.selftext)
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
      .id("post-content")
    } else {
      VStack {
        ProgressView()
          .progressViewStyle(.circular)
          .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
          .id("post-loading")
      }
    }
  }
}

struct PostReplies: View {
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  var ignoreSpecificComment: Bool
  var highlightID: String?
  var sort: CommentSortOption
  var proxy: ScrollViewProxy
  @EnvironmentObject var redditAPI: RedditAPI
  @StateObject var comments = ObservableArray<Comment>()
  @State var loading = true
  
  func asyncFetch(_ full: Bool, _ altIgnoreSpecificComment: Bool? = nil) async {
    if let result = await post.refreshPost(commentID: (altIgnoreSpecificComment ?? ignoreSpecificComment) ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task {
        await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
      }
      await MainActor.run {
        withAnimation {
            comments.data = newComments
            loading = false
        }
      }
    } else {
      await MainActor.run {
        withAnimation {
          loading = false
        }
      }
    }
  }
  
  var body: some View {
    Group {
      let commentsData = comments.data
      if commentsData.count > 0, let postFullname = post.data?.name {
        Group {
          ForEach(Array(commentsData.enumerated()), id: \.element.id) { i, comment in
            Section {
              CommentLink(post: post, subreddit: subreddit, postFullname: postFullname, parentElement: .post(comments), comment: comment)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
          }
          Section {
            Spacer()
              .frame(height: 1)
              .listRowBackground(Color.clear)
              .onChange(of: ignoreSpecificComment) { val in
                Task {
                  await asyncFetch(post.data == nil, val)
                }
                if val {
                  withAnimation(spring) {
                    proxy.scrollTo("post-content", anchor: .bottom)
                  }
                }
              }
              .id("on-change-spacer")
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
      } else {
        if loading {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: 100 )
            .listRowBackground(Color.clear)
            .onAppear {
              if comments.data.count == 0 || post.data == nil {
                Task {
                  await asyncFetch(post.data == nil)
                  //                      var specificID: String? = nil
                  if var specificID = highlightID {
                    specificID = specificID.hasPrefix("t1_") ? String(specificID.dropFirst(3)) : specificID
                    doThisAfter(0.1) {
                      withAnimation(spring) {
                        proxy.scrollTo("\(specificID)-body", anchor: .center)
                      }
                    }
                  }
                }
              }
            }
            .id("loading-comments")
        } else {
          Text("No comments around...")
            .frame(maxWidth: .infinity, minHeight: 300)
            .opacity(0.25)
            .listRowBackground(Color.clear)
            .id("no-comments-placeholder")
        }
      }
    }
  }
}

struct PostView: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  var post: Post
  @ObservedObject var subreddit: Subreddit
  var highlightID: String?
  @State var ignoreSpecificComment = false
  @State var sort: CommentSortOption = Defaults[.preferredCommentSort]
  @State var id = UUID()
  @EnvironmentObject var redditAPI: RedditAPI
  
  func asyncFetch(_ full: Bool = true) async {
    if let result = await post.refreshPost(commentID: ignoreSpecificComment ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task {
        await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
      }
    }
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      List {
        Group {
          Section {
            PostContent(post: post)

            Text("Comments")
              .padding(.top, 16)
              .fontSize(20, .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .id("comments-header")
          }
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 0, leading: preferenceShowCommentsCards ? 0 : 12, bottom: 0, trailing: preferenceShowCommentsCards ? 0 : 12))
          
          PostReplies(post: post, subreddit: subreddit, ignoreSpecificComment: ignoreSpecificComment, highlightID: highlightID, sort: sort, proxy: proxy)
          
          if !ignoreSpecificComment && highlightID != nil {
            Section {
              Button {
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
      .introspect(.list, on: .iOS(.v16, .v17)) { collectionView in
        //      collectionView.contentInset = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8)
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout {
          if let newConfig = collectionViewLayout.configuration.copy() as? UICollectionViewCompositionalLayoutConfiguration {
            newConfig.interSectionSpacing = preferenceShowCommentsCards ? -16 : 0
            collectionViewLayout.configuration = newConfig
          }
        }
      }
      .transition(.opacity)
      .environment(\.defaultMinListRowHeight, 5)
      .if(!preferenceShowCommentsCards) { $0.listStyle(.plain) }
      .refreshable {
        await asyncFetch(true)
      }
      .overlay(
        PostFloatingPill(post: post)
        , alignment: .bottomTrailing
      )
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
                SubredditIcon(data: data)
              }
            }
          }
          .animation(nil, value: sort)
      )
      .onAppear {
        if subreddit.data == nil {
          Task {
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
