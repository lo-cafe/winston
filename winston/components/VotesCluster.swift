//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI

/// A cluster that shows the amount of votes and optionally the like to dislike ratio
struct VotesCluster: View {
  var data: PostData
  var likeRatio: CGFloat?
  var body: some View {
      VStack{
        Text(formatBigNumber(data.ups))
//              .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
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
          .fontSize(11, .light)
          .foregroundColor(.gray)
        }
      }
      .padding(.horizontal, 5)
    }
}
