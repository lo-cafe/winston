//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI
import Defaults

/// A cluster consisting of the upvote, downvote button and the amount of upvotes with an optional upvote ratio
struct VotesCluster: View, Equatable {
  static let verticalWidth: Double = 24
  static func == (lhs: VotesCluster, rhs: VotesCluster) -> Bool {
    lhs.vertical == rhs.vertical && lhs.post == rhs.post && lhs.likeRatio == rhs.likeRatio
  }
  
  var likeRatio: CGFloat? //if the upvote ratio is nil it will be hidden
  @ObservedObject var post: Post
  var vertical = false
  @Default(.showUpvoteRatio) var showUpvoteRatio
  
  var body: some View {
    if let data = post.data {
      let layout = vertical ? AnyLayout(VStackLayout(spacing: 2)) : AnyLayout(HStackLayout(spacing: showUpvoteRatio ? 4 : 8))
      //    let votes = calculateUpAndDownVotes(upvoteRatio: data.upvote_ratio, score: data.ups)
      layout {
        VoteButton(color: data.likes != nil && data.likes! ? .orange : .gray, voteAction: .up,image: "arrow.up", post: post)
        
        VotesClusterInfo(ups: data.ups, likes: data.likes, likeRatio: data.upvote_ratio, vertical: vertical)
        
        VoteButton(color: data.likes != nil && !data.likes! ? .blue : .gray, voteAction: .down, image: "arrow.down", post: post)
        
        if vertical {
          Spacer().frame(maxHeight: .infinity)
        }
      }
      .frame(width: vertical ? VotesCluster.verticalWidth : nil)
    }
  }
}

struct VotesClusterInfo: View {
  var ups: Int
  var likes: Bool?
  var likeRatio: CGFloat?
  var vertical: Bool
  var body: some View {
    if !vertical {
      VStack(spacing: 0) {
        Text(formatBigNumber(ups))
          .contentTransition(.numericText())
          .foregroundColor(likes != nil ? (likes! ? .orange : .blue) : .gray)
          .fontSize(16, .semibold)
        //          .viewVotes(votes.upvotes, votes.downvotes)
        
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
    } else {
      Spacer()
    }
  }
}

struct CustomLabel: LabelStyle {
  var spacing: Double = 0.0
  
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: spacing) {
      configuration.icon
      configuration.title
    }
  }
}
