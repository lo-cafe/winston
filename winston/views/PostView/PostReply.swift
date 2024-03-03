//
//  PostReply.swift
//  winston
//
//  Created by Igor Marcossi on 03/03/24.
//

import SwiftUI

struct PostReply: View {
  var post: Post
  var subreddit: Subreddit
  var comment: Comment
  var i: Int
  @Binding var comments: [Comment]
  var highlightID: String?
  var ignoreSpecificComment: Bool
  var seenComments: String?
  @Environment(\.useTheme) private var selectedTheme
    var body: some View {
      let theme = selectedTheme.comments
      let postFullname = post.data?.name ?? ""
      let horPad = theme.theme.outerHPadding

      Section {
        
        Spacer()
          .frame(maxWidth: .infinity, minHeight: theme.spacing / 2.0, maxHeight: theme.spacing / 2.0)
//              .id("\(comment.id)-top-spacer")
        
        PostReplyBG(pos: .top)
        
        if let commentWinstonData = comment.winstonData {
          CommentLink(highlightID: ignoreSpecificComment ? nil : highlightID, post: post, subreddit: subreddit, postFullname: postFullname, seenComments: seenComments, parentElement: .post($comments), comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
            .if(comments.firstIndex(of: comment) != nil) { view in
              view.anchorPreference(
                key: CommentUtils.AnchorsKey.self,
                value: .center
              ) { [comment.id: $0] }
            }
        }
        
        PostReplyBG(pos: .bottom)
        
        Spacer()
          .frame(maxWidth: .infinity, minHeight: theme.spacing / 2.0, maxHeight: theme.spacing / 2.0)
//              .id("\(comment.id)-bot-spacer")
        
        if comments.count - 1 != i {
          NiceDivider(divider: theme.divider)
            .id("\(comment.id)-bot-divider")
        }
        
      }
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets(top: 0, leading: horPad, bottom: 0, trailing: horPad))
    }
}
