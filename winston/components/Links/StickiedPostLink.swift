//
//  StickiedPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 06/02/24.
//

import SwiftUI
import Defaults

struct StickiedPostLink: View {
  var post: Post
  var body: some View {
    if let data = post.data {
      //    Button {
      //      openPost(post)
      //    } label: {
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Image(systemName: "pin.fill").foregroundStyle(.green)
          
          Text(data.title)
            .lineLimit(2)
            .fontSize(16, .semibold)
            .fixedSize(horizontal: false, vertical: true)
        }
        Spacer()
          .frame(maxHeight: .infinity)
        
        HStack {
          
          
          HStack(alignment: .center, spacing: 6) {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "message.fill")
              Text(formatBigNumber(data.num_comments))
                .contentTransition(.numericText())
            }
            
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "hourglass.bottomhalf.filled")
              Text(timeSince(Int(data.created)))
                .contentTransition(.numericText())
            }
          }
          .font(.system(size: 13, weight: .medium))
          .compositingGroup()
          .opacity(0.5)
          
          Spacer()
          HStack(alignment: .center, spacing: 4) {
            
            Image(systemName: "arrow.up")
              .foregroundColor(.gray)
            
            Text(formatBigNumber(data.ups))
              .foregroundColor(.gray)
              .fontSize(13, .semibold)
              .transition(.asymmetric(insertion: .offset(y: 16), removal: .offset(y: -16)).combined(with: .opacity))
            //            .id(post.score)
            
            Image(systemName: "arrow.down")
              .foregroundColor(.gray)
          }
          .fontSize(13, .medium)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
        }
        
      }
      .padding(.horizontal, 13)
      .padding(.vertical, 11)
      .frame(width: (.screenW / 1.75), height: 120, alignment: .topLeading)
      .themedListRowLikeBG()
      .mask(RR(20, Color.listBG))
      .onTapGesture {
        Nav.to(.reddit(.post(post)))
      }
    }
  }
}
