//
//  ShortPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import SwiftUI
import Kingfisher
import Defaults

struct ShortPostLink: View {
  var reset: Bool
  var noHPad = false
  var post: Post
  @Default(.preferenceShowPostsAvatars) var preferenceShowPostsAvatars
  @State var opened = false
  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading) {
        Text("\(data.title.escape)")
          .fontSize(18, .semibold)
        Text((data.selftext).md()).lineLimit(2)
          .fontSize(15).opacity(0.75)
        HStack {
          if let fullname = data.author_fullname {
            Badge(showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: ["message.fill":"\(data.num_comments)", "arrow.up.arrow.down":"\(data.ups)"])
          }
          Spacer()
          FlairTag(text: "r/\(data.subreddit)", color: .blue)
            .highPriorityGesture(TapGesture() .onEnded { opened = true })
        }
      }
      .padding(.horizontal, noHPad ? 0 : 16)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(RR(20, noHPad ? .clear : .listBG))
      .onChange(of: reset) { _ in opened = false }
      .onTapGesture {
        opened = true
      }
      .background(
        NavigationLink(destination: PostViewContainer(post: post, sub: Subreddit(id: data.subreddit, api: post.redditAPI)), isActive: $opened, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
      )
    }
  }
}
