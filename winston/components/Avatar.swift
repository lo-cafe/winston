//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI

struct Avatar: View {
  var url:  String?
  let userID: String
  var fullname: String?
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  @ObservedObject private var avatarCache = AvatarCache.shared
  
  var avatarURL: URL? {
    return avatarCache[fullname ?? userID] ?? URL(string: String(url?.split(separator: "?")[0] ?? ""))
  }
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
        if let avatarURL = avatarURL {
          AvatarRaw(url: avatarURL, userID: userID, fullname: fullname, theme: theme, avatarSize: avatarSize)
            .equatable()
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

struct AvatarRaw: View, Equatable {
  static func == (lhs: AvatarRaw, rhs: AvatarRaw) -> Bool {
    lhs.url == rhs.url && lhs.avatarSize == rhs.avatarSize && lhs.userID == rhs.userID && lhs.fullname == rhs.fullname
  }
  
  var url: URL
  var userID: String
  var fullname: String? = nil
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  
  var body: some View {
    let avatarSize = avatarSize ?? theme?.size ?? 0
    let cornerRadius = (theme?.cornerRadius ?? (avatarSize / 2))
    URLImage(url: url, processors: [.resize(width: avatarSize)])
      .equatable()
      .scaledToFill()
  }
}
