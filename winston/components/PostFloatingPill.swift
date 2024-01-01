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
  @ObservedObject var post: Post
  @ObservedObject var subreddit: Subreddit
  var updateComments: (()->())?
  var showUpVoteRatio: Bool
  
  @Default(.postsInBox) private var postsInBox
  @Environment(\.useTheme) private var selectedTheme
  @State private var showReplyModal = false
  @State private var showAddedToast: Bool = false
  @State private var showRemovedToast: Bool = false
  private var thisPinnedPost: Bool { postsInBox.contains { $0.id == post.id } }
  
  var body: some View {
    Group {
      if let data = post.data {
        let permalink = "https://reddit.com\(data.permalink.escape.urlEncoded)"
        
        if !selectedTheme.posts.inlineFloatingPill {
          Group {
            HStack(spacing: 2) {
              Group {
                HStack(spacing: -12) {
                  LightBoxButton(icon: "square.and.arrow.up.fill") {
                    ShareUtils.shareItem(item: permalink)
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
                        let communityIcon = subData.community_icon?.split(separator: "?") ?? []
                        subIcon = subData.icon_img == "" || subData.icon_img == nil ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : subData.icon_img
                      }
                      let newPostInBox = PostInBox(
                        id: data.id, fullname: data.name,
                        title: data.title, body: data.selftext,
                        subredditIconURL: subIcon, img: nil,
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
                  //            .toast(isPresenting: $showAddedToast, tapToDismiss: true){
                  //              AlertToast(displayMode: .hud, type: .systemImage("plus.circle", Color.blue), title: "Added to Posts Box!")
                  //            }
                  //            .toast(isPresenting: $showRemovedToast, tapToDismiss: true){
                  //              AlertToast(displayMode: .hud, type: .systemImage("trash", Color.blue), title: "Removed from Posts Box!")
                  //            }
                  
                  LightBoxButton(icon: "arrowshape.turn.up.left.fill") {
                    withAnimation(spring) {
                      showReplyModal = true
                    }
                  }
                }
                
                HStack(alignment: .center, spacing: 8) {
                  
                  VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: false, showUpVoteRatio: showUpVoteRatio)
                  
                }
                
              }
              
            }
            .padding(.trailing, 14)
            .floating()
            .padding(.all, 8)
          }
        } else {
          Group {
            HStack { // Set spacing to 0 to make buttons stretch evenly
              if let data = post.data {
                LightBoxButton(icon: data.saved ? "bookmark.fill" : "bookmark"){
                  Task {
                    await post.saveToggle()
                  }
                }
                .padding(.vertical, -2)
              }
              
              // ShareLink button
              Spacer()
              
              LightBoxButton(icon: "square.and.arrow.up.fill") {
                ShareUtils.shareItem(item: permalink)
              }
              .padding(.vertical, -2)
              
              Spacer()
              
              // LightBoxButton for pinned post
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
                    let communityIcon = subData.community_icon?.split(separator: "?") ?? []
                    subIcon = subData.icon_img == "" || subData.icon_img == nil ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : subData.icon_img
                  }
                  let newPostInBox = PostInBox(
                    id: data.id, fullname: data.name,
                    title: data.title, body: data.selftext,
                    subredditIconURL: subIcon, img: nil,
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
              .padding(.vertical, -2)
              
              Spacer()
              
              // LightBoxButton for reply
              LightBoxButton(icon: "arrowshape.turn.up.left.fill") {
                withAnimation(spring) {
                  showReplyModal = true
                }
              }
              .padding(.vertical, -2)
              
              Spacer()
              
              // VotesCluster
              VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: false, showUpVoteRatio: showUpVoteRatio)
                .padding(.vertical, -2)
              
              Spacer()
            }
            //            .padding(.all, 4)
            .background(RR(12, selectedTheme.comments.theme.bg()))
            .frame(maxWidth: .infinity)
          }
        }
      }
    }
    .fontSize(20, .semibold)
    .foregroundColor(Color.accentColor)
    .sheet(isPresented: $showReplyModal) {
      ReplyModalPost(post: post, updateComments: updateComments)
    }
  }
}
