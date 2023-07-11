//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Kingfisher

struct Avatar: View {
  var url: String?
  var userID: String
  var fullname: String? = nil
  var avatarSize: CGFloat = 30
  @State var userData: UserData?
  @EnvironmentObject var redditAPI: RedditAPI
  var body: some View {
//    let userDataURL = userData?.subreddit?.icon_img?
//    let avatarURL = url ?? redditAPI.avatarURLCache[fullname ?? userID] ?? (userDataURL == nil ? nil : String(userDataURL!))
    let avatarURLRaw = url ?? redditAPI.avatarURLCache[fullname ?? userID] ?? userData?.subreddit?.icon_img
    let avatarURL = avatarURLRaw == nil || avatarURLRaw == "" ? nil : String(avatarURLRaw?.split(separator: "?")[0] ?? "")
    //    let avatarURL = "aksm"
    Group {
      if userID == "[deleted]" {
        Image(systemName: "trash")
          .foregroundColor(.red)
          .background(
            Circle()
              .fill(.gray.opacity(0.5))
              .frame(width: avatarSize, height: avatarSize)
          )
      } else {
        if let avatarURL = avatarURL, avatarURL != "" {
//          EmptyView()
          KFImage(URL(string: avatarURL)!)
            .resizable()
//            .placeholder {
//              Text("l\(userID.prefix(1).uppercased())")
//                .background(
//                  Circle()
//                    .fill(.gray.opacity(0.5))
//                    .frame(width: avatarSize, height: avatarSize)
//                )
//            }
            .fade(duration: 0.25)
//            .transition(.fade(duration: 0.5))
            .scaledToFill()
//            .id(avatarURL)
        } else {
          Text(userID.prefix(1).uppercased())
            .fontSize(avatarSize / 2)
            .background(
              Circle()
                .fill(.gray.opacity(0.5))
                .frame(width: avatarSize, height: avatarSize)
            )
//            .onAppear {
//              if avatarURL == nil {
//                Task {
//                  if let data = await redditAPI.fetchUserPublic(userID) {
//                    let userDataURL = data.subreddit?.icon_img?.split(separator: "?")[0]
//                    let url = userDataURL == nil ? "" : String(userDataURL!)
//                    redditAPI.avatarURLCache[userID] = url
//                    userData = data
//                  }
//                }
//              }
//            }
        }
      }
    }
    .frame(width: avatarSize, height: avatarSize)
    .mask(Circle())
  }
}
//
//struct Avatar_Previews: PreviewProvider {
//    static var previews: some View {
//        Avatar()
//    }
//}
