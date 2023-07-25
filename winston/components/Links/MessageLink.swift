//
//  InboxNotification.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import SwiftUI
import Defaults

struct MessageLink: View {
  var reset: Bool
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.preferenceShowPostsAvatars) var preferenceShowPostsAvatars
  @State var openedPost = false
  @State var pressed = false
  @ObservedObject var message: Message
  
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
      .allowsHitTesting(false)
      .onChange(of: reset) { _ in openedPost = false }
      .background(
        data.context == nil
        ? nil
        : NavigationLink(destination: PostViewContainer(post: Post(id: getPostId(from: data.context!) ?? "lol", api: message.redditAPI), sub: Subreddit(id: subreddit, api: message.redditAPI), highlightID: actualParentID), isActive: $openedPost, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
      )
      .padding(.horizontal, preferenceShowPostsCards ? 16 : 0)
      .padding(.vertical, preferenceShowPostsCards ? 12 : 0)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .if(preferenceShowPostsCards) { view in
        view
          .background(RR(20, .listBG).allowsHitTesting(false))
          .mask(RR(20, .black))
      }
      .compositingGroup()
      .opacity(!(data.new ?? false) ? 0.65 : 1)
      .swipyActions(pressing: $pressed, onTap: {
        openedPost = true
      }, rightActionIcon: !(data.new ?? false) ? "eye.slash.fill" : "eye.fill", rightActionHandler: {
        Task {
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
