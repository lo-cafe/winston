//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI
import SimpleHaptics
import Defaults
/// A cluster consisting of the upvote, downvote button and the amount of upvotes with an optional upvote ratio
struct VotesCluster: View {
  var data: PostData
  var likeRatio: CGFloat? //if the upvote ratio is nil it will be hidden
  var post: Post
  @Default(.showUpvoteRatio) var showUpvoteRatio
  
  var body: some View {
    HStack(spacing: showUpvoteRatio ? 4 : 8){
      VoteButton(color: data.likes != nil && data.likes! ? .orange : .gray, voteAction: .up,image: "arrow.up", post: post)
      
      VStack{
        Text(formatBigNumber(data.ups))
          .foregroundColor(data.likes != nil ? (data.likes! ? .orange : .blue) : .gray)
          .fontSize(16, .semibold)
//          .viewVotes(data.ups, data.downs)
          .zIndex(10)
        
        if likeRatio != nil, let ratio = likeRatio {
          Label(title: {
            Text(String(Int(ratio * 100)) + "%")
          }, icon: {
            Image(systemName: "face.smiling")
          })
          .labelStyle(CustomLabel(spacing: 1))
          .fontSize(12, .medium)
          .foregroundColor(.gray)
        }
      }
      .padding(.horizontal, 0)
      
      VoteButton(color: data.likes != nil && !data.likes! ? .blue : .gray, voteAction: .down, image: "arrow.down", post: post)
    }
  }
  
}
