//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct Avatar: View {
  var userID: String
  @State var userData: UserData?
  @EnvironmentObject var redditAPI: RedditAPI
  var body: some View {
    Group {
      if let iconFull = userData?.subreddit?.icon_img, iconFull != "" {
        let icon = String(iconFull.split(separator: "?")[0])
          WebImage(url: URL(string: icon))
            .resizable()
            .placeholder {
              Text(userID.prefix(1))
                .background(
                  Circle()
                    .fill(.gray.opacity(0.5))
                )
            }
            .scaledToFill()
      } else {
        Text(userID.prefix(1).uppercased())
          .background(
            Circle()
              .fill(.gray.opacity(0.5))
              .frame(width: 30, height: 30)
          )
          .onAppear {
            Task {
              if let data = await redditAPI.fetchUser(userID) {
                userData = data
              }
            }
          }
      }
    }
    .frame(width: 30, height: 30)
    .mask(Circle())
  }
}
//
//struct Avatar_Previews: PreviewProvider {
//    static var previews: some View {
//        Avatar()
//    }
//}
