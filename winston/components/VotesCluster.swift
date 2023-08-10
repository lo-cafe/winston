//
//  VotingCluster.swift
//  winston
//
//  Created by Daniel Inama on 10/08/23.
//

import SwiftUI

struct VotesCluster: View {
  var data: PostData
  var body: some View {
      let downup = Int(data.ups - data.downs)
      VStack{
        Text(formatBigNumber(downup))
//              .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
          .foregroundColor(data.likes != nil ? (data.likes! ? .orange : .blue) : .gray)
          .fontSize(16, .semibold)
          .viewVotes(data.ups, data.downs)
          .zIndex(10)
        Label(title: {
          Text(String(Double(abs(downup) / data.ups) * 100) + "%")
        }, icon: {
          Image(systemName: "face.smiling")
        })
        .labelStyle(CustomLabel(spacing: 1))
        .fontSize(12, .light)
        .foregroundColor(downup < 0 ? .blue : .gray)
      }
      .padding(.horizontal, 5)
    }
}
