//
//  PostFloatingPill.swift
//  winston
//
//  Created by Igor Marcossi on 06/07/23.
//

import SwiftUI

struct PostFloatingPill: View {
  @ObservedObject var post: Post
  @State var showReplyModal = false
  var body: some View {
    HStack(spacing: 0) {
      if let data = post.data {
        Group {
          
//          LightBoxButton(icon: "bookmark.fill") {
//
//          }
          HStack(spacing: -12) {
            LightBoxButton(icon: "square.and.arrow.up.fill") {
              //            if let data = post.data {
              //              ShareLink(item: URL(data.url)!)
              //            }
            }
            
            LightBoxButton(icon: "arrowshape.turn.up.left.fill") {
              withAnimation(spring) {
                showReplyModal = true
              }
            }
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
        
      }
    }
    .fontSize(20, .semibold)
    .foregroundColor(.blue)
    .padding(.trailing, 14)
//    .padding(.vertical, 8)
    .floating()
    .padding(.all, 8)
    .sheet(isPresented: $showReplyModal) {
      ReplyModalPost(post: post)
    }
  }
}
//
//struct PostFloatingPill_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFloatingPill()
//    }
//}
