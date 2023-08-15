//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import NukeUI

struct Avatar: View {
//  static func == (lhs: Avatar, rhs: Avatar) -> Bool {
//    AvatarCache.shared.data[fullname ?? userID] == AvatarCache.shared.data[fullname ?? userID]
//  }
  
  var url: String?
  var userID: String
  var fullname: String? = nil
  var avatarSize: CGFloat = 30
  @EnvironmentObject var redditAPI: RedditAPI
  @ObservedObject var avatarCache = AvatarCache.shared
  
  var avatarURL: String? {
    let raw = url ?? avatarCache[fullname ?? userID]
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
          LazyImage(url: avatarURLURL) { state in
            if let image = state.image {
              image.resizable().scaledToFill()
            } else if state.error != nil {
              Color.red // Indicates an error
            } else {
              Color.blue // Acts as a placeholder
            }
          }
        } else {
          Text(userID.prefix(1).uppercased())
            .fontSize(avatarSize / 2)
            .background(
              Circle()
                .fill(.gray.opacity(0.5))
                .frame(width: avatarSize, height: avatarSize)
            )
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
