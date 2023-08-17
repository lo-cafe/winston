//
//  PostReplies.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI
import Defaults

struct PostReplies: View {
  @Default(.preferenceShowCommentsCards) private var preferenceShowCommentsCards
  @Default(.commentsInnerHPadding) private var commentsInnerHPadding
  @Default(.cardedCommentsOuterHPadding) private var cardedCommentsOuterHPadding
  var update: Bool
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  var ignoreSpecificComment: Bool
  var highlightID: String?
  var sort: CommentSortOption
  var proxy: ScrollViewProxy
  @EnvironmentObject private var redditAPI: RedditAPI
  @StateObject private var comments = ObservableArray<Comment>()
  @ObservedObject private var globalLoader = TempGlobalState.shared.globalLoader
  @State private var loading = true
  
  func asyncFetch(_ full: Bool, _ altIgnoreSpecificComment: Bool? = nil) async {
    if let result = await post.refreshPost(commentID: (altIgnoreSpecificComment ?? ignoreSpecificComment) ? nil : highlightID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
      Task(priority: .background) {
        await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
      }
      newComments.forEach { $0.parentWinston = comments }
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
    let horPad = preferenceShowCommentsCards ? cardedCommentsOuterHPadding : commentsInnerHPadding
    Group {
      let commentsData = comments.data
      if commentsData.count > 0, let postFullname = post.data?.name {
        Group {
          ForEach(Array(commentsData.enumerated()), id: \.element.id) { i, comment in
            Section {
              if preferenceShowCommentsCards {
                Spacer()
                  .frame(maxWidth: .infinity, minHeight: 24, maxHeight: 24)
                  .background(CommentBG(pos: .top).fill(Color.listBG))
                  .frame(maxWidth: .infinity, minHeight: 13, maxHeight: 13, alignment: .top)
                  .clipped()
                  .id("\(comment.id)-top-decoration")
                  .listRowInsets(EdgeInsets(top: 6, leading: horPad, bottom: 0, trailing: horPad))
              } else {
                Spacer()
                  .frame(maxWidth: .infinity, minHeight: 8, maxHeight: 8)
                  .id("\(comment.id)-top-spacer")
              }
              CommentLink(highlightID: ignoreSpecificComment ? nil : highlightID, post: post, subreddit: subreddit, postFullname: postFullname, parentElement: .post(comments), comment: comment)
              if preferenceShowCommentsCards {
                Spacer()
                  .frame(maxWidth: .infinity, minHeight: 24, maxHeight: 24)
                  .background(CommentBG(pos: .bottom).fill(Color.listBG))
                  .frame(maxWidth: .infinity, minHeight: 13, maxHeight: 13, alignment: .bottom)
                  .clipped()
                  .id("\(comment.id)-bot-decoration")
                  .listRowInsets(EdgeInsets(top: 0, leading: horPad, bottom: 6, trailing: horPad))
              } else {
                VStack {
                  Spacer()
                    .frame(maxWidth: .infinity, minHeight: 8, maxHeight: 8)
                  if commentsData.count - 1 != i {
                    Divider()
                  }
                }
                .id("\(comment.id)-bot-spacer")
              }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: horPad, bottom: 0, trailing: horPad))
          }
          Section {
            Spacer()
              .frame(height: 1)
              .listRowBackground(Color.clear)
              .onChange(of: update) { _ in
                Task(priority: .background) {
                  await asyncFetch(true)
                }
              }
              .onChange(of: ignoreSpecificComment) { val in
                Task(priority: .background) {
                  await asyncFetch(post.data == nil, val)
                  globalLoader.dismiss()
                }
                if val {
                  withAnimation(spring) {
                    proxy.scrollTo("post-content", anchor: .bottom)
                  }
                }
              }
              .id("on-change-spacer")
          }
          .listRowBackground(Color.clear)
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
                Task(priority: .background) {
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
            .onChange(of: update) { _ in
              Task(priority: .background) {
                await asyncFetch(true)
              }
            }
            .id("no-comments-placeholder")
        }
      }
    }
  }
}
