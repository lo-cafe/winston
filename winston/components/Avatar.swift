//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import LonginusSwiftUI

struct Avatar: View {
//  static func == (lhs: Avatar, rhs: Avatar) -> Bool {
//    AvatarCache.shared.data[fullname ?? userID] == AvatarCache.shared.data[fullname ?? userID]
//  }
  
  var url: String?
  var userID: String
  var fullname: String? = nil
  var avatarSize: CGFloat = 30
  @State var userData: UserData?
  @EnvironmentObject var redditAPI: RedditAPI
  @ObservedObject var avatarCache = AvatarCache.shared
  
  var avatarURL: String? {
    let raw = url ?? avatarCache[fullname ?? userID] ?? userData?.subreddit?.icon_img
    return raw == nil || raw == "" ? nil : String(raw?.split(separator: "?")[0] ?? "")
  }
  
  var body: some View {
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
        if let avatarURL = avatarURL, avatarURL != "", let avatarURLURL = URL(string: avatarURL) {
//          EmptyView()
          LGImage(source: avatarURLURL, placeholder: {
            ProgressView()
          }, options: [.imageWithFadeAnimation])
            .resizable()
            .cancelOnDisappear(true)
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
            .onAppear {
              if avatarURL.isNil {
                Task {
                  if let data = await redditAPI.fetchUserPublic(userID) {
                    let userDataURL = data.subreddit?.icon_img?.split(separator: "?")[0]
                    let url = userDataURL == nil ? "" : String(userDataURL!)
                    withAnimation {
                      avatarCache[userID] = url
                      userData = data
                    }
                  }
                }
              }
            }
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
