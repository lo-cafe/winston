//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import NukeUI
import Nuke

struct Avatar: View {
  var url:  String?
  let userID: String
  var fullname: String?
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  @ObservedObject private var avatarCache = Caches.avatars
  
  var body: some View {
    let id = fullname ?? userID
    let avatarRequest = avatarCache.cache[id]
    let avatarSize = avatarSize ?? theme?.size ?? 0
//    let newURL = avatarRequest.isNil ? URL(string: String(url?.split(separator: "?")[0] ?? "")) : nil
    AvatarRaw(avatarImgRequest: avatarRequest?.data, userID: userID, fullname: fullname, theme: theme, avatarSize: avatarSize)
//      .equatable()
//      .task { if avatarRequest.isNil, let url = url { RedditAPI.shared.addImgReqToAvatarCache(id, url, avatarSize: avatarSize) } }
  }
}

struct AvatarRaw: View, Equatable {
  static func == (lhs: AvatarRaw, rhs: AvatarRaw) -> Bool {
    lhs.avatarImgRequest?.url == rhs.avatarImgRequest?.url
  }
  
  var avatarImgRequest: ImageRequest?
  var userID: String
  var fullname: String? = nil
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  
  var body: some View {
    let avatarSize = avatarSize ?? theme?.size ?? 0
    let cornerRadius = (theme?.cornerRadius ?? (avatarSize / 2))
    Group {
      if userID == "[deleted]" {
        Image(systemName: "trash")
          .foregroundColor(.red)
          .background(
            RR(cornerRadius, Color.gray.opacity(0.5))
              .frame(width: avatarSize, height: avatarSize)
          )
      } else {
        if let avatarImgRequest = avatarImgRequest, let url = avatarImgRequest.url {
          URLImage(url: url, imgRequest: avatarImgRequest, processors: [.resize(width: avatarSize)])
//            .equatable()
            .scaledToFill()
        } else {
          Text(userID.prefix(1).uppercased())
            .fontSize(avatarSize / 2)
            .background(
              RR(cornerRadius, .gray.opacity(0.5))
                .frame(width: avatarSize, height: avatarSize)
            )
        }
      }
    }
    .frame(width: avatarSize, height: avatarSize)
    .mask(RR(cornerRadius, .black))
  }
}
