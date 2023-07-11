//
//  SubredditLink.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import SwiftUI
import Kingfisher

struct SubredditLink: View {
  var reset: Bool
  var sub: Subreddit
  @State var opened = false
    var body: some View {
      if let data = sub.data {
        HStack(spacing: 12) {
          if let icon = data.icon_img, icon != "" {
            KFImage(URL(string: icon))
              .resizable()
              .frame(width: 64, height: 64)
              .mask(Circle())
          } else {
            Text(data.display_name ?? "?")
              .frame(width: 64, height: 64)
              .background(Circle().fill(Color.hex(data.primary_color ?? data.key_color ?? "fafafa")))
          }
          
          VStack(alignment: .leading) {
            Text("r/\(data.display_name ?? "?")")
              .fontSize(18, .semibold)
            Text("\(formatBigNumber(data.subscribers ?? 0)) subscribers")
              .fontSize(14).opacity(0.5)
            Text((data.public_description).md()).lineLimit(2)
              .fontSize(15).opacity(0.75)
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
          NavigationLink(destination: SubredditPosts(subreddit: sub), isActive: $opened, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
        )
      }
    }
}

//struct SubredditLink_Previews: PreviewProvider {
//    static var previews: some View {
//        SubredditLink()
//    }
//}
