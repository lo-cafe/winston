//
//  PostFloatingPill.swift
//  winston
//
//  Created by Igor Marcossi on 06/07/23.
//

import SwiftUI
import Defaults

struct PostFloatingPill: View {
  @Default(.postsInBox) var postsInBox
  
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  @State var showReplyModal = false
  
  var thisPinnedPost: Bool { postsInBox.contains { $0.id == post.id } }
  
  var body: some View {
    HStack(spacing: 2) {
      if let data = post.data {
        Group {
          
          //          LightBoxButton(icon: "bookmark.fill") {
          //
          //          }µ
          HStack(spacing: -12) {
            if let perma = URL(string: "https://reddit.com\(data.permalink.escape.urlEncoded)") {
              ShareLink(item: perma) {
                LightBoxButton(icon: "square.and.arrow.up.fill", disabled: true)
              }
            }
            
            LightBoxButton(icon: !thisPinnedPost ? "shippingbox" : "shippingbox.and.arrow.backward.fill") {
              if thisPinnedPost {
                withAnimation(spring) {
                  postsInBox = postsInBox.filter({ $0.id != post.id })
                }
              } else {
                var subIcon: String?
                if let subData = subreddit.data {
                  let communityIcon = subData.community_icon.split(separator: "?")
                  subIcon = subData.icon_img == "" || subData.icon_img == nil ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : subData.icon_img
                }
                let newPostInBox = PostInBox(
                  id: data.id, fullname: data.name,
                  title: data.title, body: data.selftext,
                  subredditIconURL: subIcon, img: data.url,
                  subredditName: data.subreddit, authorName: data.author,
                  score: data.ups, commentsCount: data.num_comments,
                  createdAt: data.created, lastUpdatedAt: Date().timeIntervalSince1970
                )
                withAnimation(spring) {
                  postsInBox.append(newPostInBox)
                }
              }
            }
            
            LightBoxButton(icon: "arrowshape.turn.up.left.fill") {
              withAnimation(spring) {
                showReplyModal = true
              }
            }
          }
          
          HStack(alignment: .center, spacing: 8) {
            Button {
              Task {
                await post.vote(action: .up)
              }
            } label: {
              Image(systemName: "arrow.up")
            }
            .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
            
            VotesCluster(data: data)
            
            Button {
              Task {
                await post.vote(action: .down)
              }
            } label: {
              Image(systemName: "arrow.down")
            }
            .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
          }
          
        }
        
      }
    }
    .fontSize(20, .semibold)
    .foregroundColor(.blue)
    .padding(.trailing, 14)
    //    .padding(.vertical, 8)
    .floating()
    .padding(.all, 8)
    .sheet(isPresented: $showReplyModal) {
      ReplyModalPost(post: post)
    }
  }
}
//
//struct PostFloatingPill_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFloatingPill()
//    }
//}
