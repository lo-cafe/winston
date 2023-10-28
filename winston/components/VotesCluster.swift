//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI
import Defaults

struct VotesKit: Equatable, Identifiable {
  let ups: Int
  let ratio: Double
  let likes: Bool?
  let id: String
}

/// A cluster consisting of the upvote, downvote button and the amount of upvotes with an optional upvote ratio
struct VotesCluster: View, Equatable {
  static let verticalWidth: Double = 24
    static func == (lhs: VotesCluster, rhs: VotesCluster) -> Bool {
      lhs.votesKit == rhs.votesKit
    }
  
//  var likeRatio: CGFloat? //if the upvote ratio is nil it will be hidden
  var votesKit: VotesKit
//  @ObservedObject var post: Post
  var voteAction: (RedditAPI.VoteAction) async -> Bool?
  
  var vertical = false
//  @Default(.showUpvoteRatio) var showUpvoteRatio
  
  nonisolated func haptic() {
    Task(priority: .background) {
      let medium = await UIImpactFeedbackGenerator(style: .medium)
      await medium.prepare()
      await medium.impactOccurred()
    }
  }
  
  nonisolated func upvote() {
    Task(priority: .background) {
      haptic()
      _ = await voteAction(.up)
    }
  }
  
  nonisolated func downvote() {
    Task(priority: .background) {
      haptic()
      _ = await voteAction(.down)
    }
  }
  
  var body: some View {
      //    let votes = calculateUpAndDownVotes(upvoteRatio: votesKit.ratio, score: votesKit.ups)
      if vertical {
        VotesClusterVertical(id: votesKit.id, likes: votesKit.likes, upvote: upvote, downvote: downvote)
      } else {
        VotesClusterHorizontal(likes: votesKit.likes, ups: votesKit.ups, upvote_ratio: votesKit.ratio, showUpvoteRatio: true, upvote: upvote, downvote: downvote)
      }
  }
}

struct VotesClusterHorizontal: View, Equatable {
  static func == (lhs: VotesClusterHorizontal, rhs: VotesClusterHorizontal) -> Bool {
    lhs.likes == rhs.likes && lhs.ups == rhs.ups && lhs.upvote_ratio == rhs.upvote_ratio && lhs.showUpvoteRatio == rhs.showUpvoteRatio
  }
  
  let likes: Bool?
  let ups: Int
  let upvote_ratio: Double
  let showUpvoteRatio: Bool
  let upvote: () -> ()
  let downvote: () -> ()
  var body: some View {
    HStack(spacing: showUpvoteRatio ? 4 : 8) {
      if #available(iOS 17, *) {
        VoteButton(active: (likes ?? false), color: .orange, image: "arrow.up").equatable().onTapGesture(perform: upvote)
      } else {
        VoteButtonFallback(color: (likes ?? false) ? .orange : .gray, voteAction: upvote, image: "arrow.up")
      }
      
      VotesClusterInfo(ups: ups, likes: likes, likeRatio: upvote_ratio)
        .allowsHitTesting(false)
      
      if #available(iOS 17, *) {
        VoteButton(active: !(likes ?? true), color: .blue ,image: "arrow.down").equatable().onTapGesture(perform: downvote)
      } else {
        VoteButtonFallback(color: !(likes ?? true) ? .blue : .gray, voteAction: downvote, image: "arrow.down")
      }
    }
    .drawingGroup()
  }
}

struct VotesClusterVertical: View, Equatable {
  static func == (lhs: VotesClusterVertical, rhs: VotesClusterVertical) -> Bool {
    lhs.likes == rhs.likes && lhs.id == rhs.id
  }
  
  var id: String
  let likes: Bool?
  let upvote: () -> ()
  let downvote: () -> ()
  var body: some View {
    VStack(spacing: 12) {
      if #available(iOS 17, *) {
        VoteButton(active: (likes ?? false), color: .orange, image: "arrow.up").equatable().onTapGesture(perform: upvote)
      } else {
        VoteButtonFallback(color: (likes ?? false) ? .orange : .gray, voteAction: upvote, image: "arrow.up")
      }
      
      if #available(iOS 17, *) {
        VoteButton(active: !(likes ?? true), color: .blue, image: "arrow.down").equatable().onTapGesture(perform: downvote)
      } else {
        VoteButtonFallback(color: !(likes ?? true) ? .blue : .gray, voteAction: downvote, image: "arrow.down")
      }
      
      Spacer().frame(maxHeight: .infinity)
    }
    .frame(width: VotesCluster.verticalWidth)
  }
}

struct VotesClusterInfo: View, Equatable {
  var ups: Int
  var likes: Bool?
  var likeRatio: CGFloat?
  var body: some View {
    VStack(spacing: 0) {
      Text(formatBigNumber(ups))
        .contentTransition(.numericText())
        .foregroundColor(likes != nil ? (likes! ? .orange : .blue) : .gray)
        .fontSize(16, .semibold)
      //          .viewVotes(votes.upvotes, votes.downvotes)
      
      if likeRatio != nil, let ratio = likeRatio {
        HStack(spacing: 1) {
          Image(systemName: "face.smiling")
          Text(String(Int(ratio * 100)) + "%")
        }
        .fontSize(12, .medium)
        .foregroundColor(.gray)
      }
    }
  }
}
