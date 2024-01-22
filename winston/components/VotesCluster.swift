//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI
import Defaults
import Pow

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
  var showUpVoteRatio: Bool
  
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
      VotesClusterHorizontal(id: votesKit.id, likes: votesKit.likes, ups: votesKit.ups, upvote_ratio: votesKit.ratio, upvote: upvote, downvote: downvote, showUpVoteRatio: showUpVoteRatio)
    }
  }
}

struct VotesClusterHorizontal: View, Equatable {
  static func == (lhs: VotesClusterHorizontal, rhs: VotesClusterHorizontal) -> Bool {
    lhs.id == rhs.id && lhs.likes == rhs.likes && lhs.ups == rhs.ups && lhs.upvote_ratio == rhs.upvote_ratio && lhs.showUpVoteRatio == rhs.showUpVoteRatio
  }
  
  let id: String
  let likes: Bool?
  let ups: Int
  let upvote_ratio: Double
  let upvote: () -> ()
  let downvote: () -> ()
  var showUpVoteRatio: Bool
  var body: some View {
    HStack(spacing: showUpVoteRatio ? 4 : 8) {
      VoteButton(active: (likes ?? false), color: .orange, image: "arrow.up").onTapGesture(perform: upvote)
      
      VotesClusterInfo(ups: ups, likes: likes, likeRatio: upvote_ratio, showUpVoteRatio: showUpVoteRatio).allowsHitTesting(false)
      
      VoteButton(active: !(likes ?? true), color: .blue ,image: "arrow.down").onTapGesture(perform: downvote)
    }
    .scaleEffect(1)
    //    .drawingGroup()
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
      VoteButton(active: (likes ?? false), color: .orange, image: "arrow.up").highPriorityGesture(TapGesture().onEnded(upvote))
      
      VoteButton(active: !(likes ?? true), color: .blue, image: "arrow.down").highPriorityGesture(TapGesture().onEnded(downvote))
      
      Spacer().frame(maxHeight: .infinity)
    }
    .frame(width: VotesCluster.verticalWidth)
  }
}

struct FlyingNumberInfo: Equatable {
  var counter: Int
  var value: Int = 0
  var color: Bool?
}

struct VotesClusterInfo: View {
  var ups: Int
  var likes: Bool?
  var likeRatio: CGFloat?
  var showUpVoteRatio: Bool
  
  @State var flyingNumber: FlyingNumberInfo
  
  init(ups: Int, likes: Bool? = nil, likeRatio: CGFloat? = nil, showUpVoteRatio: Bool) {
    self.ups = ups
    self.likes = likes
    self.likeRatio = likeRatio
    self.showUpVoteRatio = showUpVoteRatio
    self._flyingNumber = .init(initialValue: FlyingNumberInfo(counter: 0, color: likes))
  }
  
  var body: some View {
    VStack(spacing: 0) {
      Text(formatBigNumber(ups))
        .contentTransition(.numericText())
        .foregroundColor(likes != nil ? (likes! ? .orange : .blue) : .gray)
        .fontSize(16, .semibold)
        .changeEffect(
          .rise(origin: UnitPoint(x: 0.75, y: 0.25)) {
            Text(flyingNumber.value > 0 ? "+\(flyingNumber.value)" : "\(flyingNumber.value)" )
              .foregroundStyle(flyingNumber.color == true ? .orange : flyingNumber.color == nil ? .gray : .blue)
              .font(.system(size: 12, weight: .semibold))
          },
          value: flyingNumber
        )
      if showUpVoteRatio {
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
    .onChange(of: ups) { oldValue, newValue in
      flyingNumber.counter += 1
      flyingNumber.value = newValue - oldValue
      flyingNumber.color = likes
    }
  }
}
