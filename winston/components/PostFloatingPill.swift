//
//  PostFloatingPill.swift
//  winston
//
//  Created by Igor Marcossi on 06/07/23.
//

import SwiftUI
import Defaults
import AlertToast

struct PostFloatingPill: View {
  @Default(.postsInBox) var postsInBox
  @Default(.showUpvoteRatio) var showUpvoteRatio
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  @State var showReplyModal = false
  var updateComments: (()->())?

  @State var showAddedToast: Bool = false
  @State var showRemovedToast: Bool = false
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
                withAnimation(nil){
                  showRemovedToast.toggle()
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
                withAnimation(spring){
                  postsInBox.append(newPostInBox)

                }
                withAnimation(nil){
                  showAddedToast.toggle()
                }
              }
            }
            .toast(isPresenting: $showAddedToast, tapToDismiss: true){
              AlertToast(displayMode: .hud, type: .systemImage("plus.circle", Color.blue), title: "Added to Posts Box!")
            }
            .toast(isPresenting: $showRemovedToast, tapToDismiss: true){
              AlertToast(displayMode: .hud, type: .systemImage("trash", Color.blue), title: "Removed from Posts Box!")
            }
            
            LightBoxButton(icon: "arrowshape.turn.up.left.fill") {
              withAnimation(spring) {
                showReplyModal = true
              }
            }
          }
          
          HStack(alignment: .center, spacing: 8) {
  
            VotesCluster(data: data, likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post)
            
          }
          
        }
        
      }
    }
    .fontSize(20, .semibold)
    .foregroundColor(.blue)
    .padding(.trailing, 14)

    .floating()
    .padding(.all, 8)
    .sheet(isPresented: $showReplyModal) {
      ReplyModalPost(post: post, updateComments: updateComments)
    }
  }
}
//
//struct PostFloatingPill_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFloatingPill()
//    }
//}
