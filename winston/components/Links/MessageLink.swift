//
//  InboxNotification.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import SwiftUI
import Defaults

struct MessageLink: View {
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @Default(.preferenceShowPostsAvatars) private var preferenceShowPostsAvatars
  @State private var pressed = false
  @StateObject var attrStrLoader = AttributedStringLoader()
  @ObservedObject var message: Message
  @EnvironmentObject private var routerProxy: RouterProxy
  
  var body: some View {
    if let data = message.data, let author = data.author, let subreddit = data.subreddit, let parentID = data.parent_id, let name = data.name {
      let actualParentID = parentID.hasPrefix("t3_") ? name : parentID
      HStack(alignment: .top) {
        Image(systemName: data.type == "post_reply" ? "message.circle.fill" : "arrowshape.turn.up.left.circle.fill")
          .fontSize(24, .bold)
          .foregroundColor(data.type == "post_reply" ? .blue : .green)
        VStack(alignment: .leading, spacing: 2) {
          Text("**u/\(author)** \(data.type == "post_reply" ? "commented on your post" : "replied to your comment") in **r/\(subreddit)**")
          //            CommentLink(lineLimit: 2, showReplies: false, comment: comment)
          Text((data.body ?? "").md()).lineLimit(2).fontSize(15).opacity(0.75)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .themedListRowBG()
      .mask(RR(20, .black))
      .allowsHitTesting(false)
      .compositingGroup()
      .opacity(!(data.new ?? false) ? 0.65 : 1)
      .swipyActions(pressing: $pressed, onTap: {
        if data.context != nil {
          routerProxy.router.path.append(PostViewPayload(post: Post(id: getPostId(from: data.context!) ?? "lol", api: message.redditAPI), postSelfAttr: attrStrLoader.data, sub: Subreddit(id: subreddit, api: message.redditAPI), highlightID: actualParentID))
        }
      }, rightActionIcon: !(data.new ?? false) ? "eye.slash.fill" : "eye.fill", rightActionHandler: {
        Task(priority: .background) {
          await message.toggleRead()
        }
      })
    }
  }
}

//struct InboxNotification_Previews: PreviewProvider {
//    static var previews: some View {
//        InboxNotification()
//    }
//}
