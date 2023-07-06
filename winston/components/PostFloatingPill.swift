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
              Text("\(downup > 999 ? downup / 1000 : downup)\(downup > 999 ? "K" : "")")
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
        .background(Capsule(style: .continuous).fill(.ultraThinMaterial))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.05), lineWidth: 1).padding(.all, 0.5))
        .padding(.all, 8)
    }
}
//
//struct PostFloatingPill_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFloatingPill()
//    }
//}
