//
//  PostFloatingPill.swift
//  winston
//
//  Created by Igor Marcossi on 06/07/23.
//

import SwiftUI

struct PostFloatingPill: View {
  @ObservedObject var post: Post
    var body: some View {
      HStack(spacing: 16) {
        if let data = post.data {
          Group {
            Button { } label: {
              Image(systemName: "bookmark.fill")
            }
            
            Button { } label: {
              Image(systemName: "square.and.arrow.up.fill")
            }
            
            Button { } label: {
              Image(systemName: "arrowshape.turn.up.left.fill")
            }
            
            HStack(alignment: .center, spacing: 6) {
              Button {
                Task {
                  await post.vote(action: .up)
                }
              } label: {
                Image(systemName: "arrow.up")
              }
              .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
              
              let downup = Int(data.ups - data.downs)
              Text(formatBigNumber(downup))
                .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                .fontSize(16, .semibold)
              
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
          .padding(.all, 4)
          
        }
      }
        .fontSize(20, .semibold)
        .foregroundColor(.blue)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .floating()
        .padding(.all, 8)
    }
}
//
//struct PostFloatingPill_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFloatingPill()
//    }
//}
