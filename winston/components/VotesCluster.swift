//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI
import SimpleHaptics
/// A cluster consisting of the upvote, downvote button and the amount of upvotes with an optional upvote ratio
struct VotesCluster: View {
  var data: PostData
  var likeRatio: CGFloat? //if the upvote ratio is nil it will be hidden
  var post: Post

  var body: some View {
    HStack(){
      VoteButton(color: data.likes != nil && data.likes! ? .orange : .gray, voteAction: .up,image: "arrow.up", post: post)
      
        VStack{
          Text(formatBigNumber(data.ups))
            .foregroundColor(data.likes != nil ? (data.likes! ? .orange : .blue) : .gray)
            .fontSize(16, .semibold)
            .viewVotes(data.ups, data.downs)
            .zIndex(10)
         
          if likeRatio != nil, let ratio = likeRatio {
            Label(title: {
              Text(String(Int(ratio * 100)) + "%")
            }, icon: {
              Image(systemName: "face.smiling")
            })
            .labelStyle(CustomLabel(spacing: 1))
            .fontSize(12, .light)
            .foregroundColor(.gray)
          }
        }
        .padding(.horizontal, 5)
      
      VoteButton(color: data.likes != nil && !data.likes! ? .blue : .gray, voteAction: .down, image: "arrow.down", post: post)
    }
}

struct VoteButton: View {
  var color: Color
  var voteAction: RedditAPI.VoteAction
  var image: String
  var post: Post
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  @State private var animate = true

  var body: some View {
    Button {
      try? haptics.fire(intensity:  0.35, sharpness: 0.5)
      animate = false
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
        animate = true
      }
      Task {
        await post.vote(action: voteAction)
      }
    } label: {
      Image(systemName: image)
    }
    .buttonStyle(ScaleButtonStyle(scaleDepressed: 1, scalePressed: 1.2)) //Deperecated, but when I delete it the buttons in the feed stop working -_-
    .foregroundColor(color)
    .scaleEffect(animate ? 1 : 1.3)
    }
  }
}
