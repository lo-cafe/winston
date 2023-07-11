//
//  SwiftUIView.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import SwiftUI
import Kingfisher

struct UserLink: View {
  var reset: Bool
  var user: User
  @State var opened = false
    var body: some View {
      if let data = user.data {
        HStack(spacing: 12) {
          Avatar(url: data.icon_img, userID: data.name, avatarSize: 64)
          
          VStack(alignment: .leading) {
            Text("r/\(data.name)")
              .fontSize(18, .semibold)
            Text("\(formatBigNumber(data.total_karma ?? ((data.link_karma ?? 0) + (data.comment_karma ?? 0)))) karma")
              .fontSize(14).opacity(0.5)
            if let description = data.subreddit?.public_description {
              Text((description).md()).lineLimit(2)
                .fontSize(15).opacity(0.75)
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RR(20, .secondary.opacity(0.15)))
        .onChange(of: reset) { _ in opened = false }
        .onTapGesture {
          opened = true
        }
        .background(
          NavigationLink(destination: UserView(user: user), isActive: $opened, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
        )
      }
    }
}
