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
  var saved = false
  var url:  String?
  let userID: String
  var fullname: String?
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  var avatarRequest: ImageRequest?
//  @ObservedObject var avatarCache: BaseCache<ImageRequest>
  
  var body: some View {
    let avatarSize = avatarSize ?? theme?.size ?? 0
    
      //    let newURL = avatarRequest == nil ? URL(string: String(url?.split(separator: "?")[0] ?? "")) : nil
      AvatarRaw(saved: saved, avatarImgRequest: avatarRequest, userID: userID, fullname: fullname, theme: theme, avatarSize: avatarSize)
//          .equatable()
    //      .task { if avatarRequest == nil, let url = url { RedditAPI.shared.addImgReqToAvatarCache(id, url, avatarSize: avatarSize) } }
  }
}

struct AvatarRaw: View, Equatable {
  static func == (lhs: AvatarRaw, rhs: AvatarRaw) -> Bool {
    lhs.saved == rhs.saved && lhs.avatarImgRequest?.url == rhs.avatarImgRequest?.url && lhs.theme == rhs.theme && rhs.avatarSize == lhs.avatarSize
  }
  var saved: Bool
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
            RR(cornerRadius, Color.gray.opacity(0.5)).equatable()
              .frame(width: avatarSize, height: avatarSize)
          )
      } else {
        if let avatarImgRequest = avatarImgRequest {
          ThumbReqImage(imgRequest: avatarImgRequest)
        } else {
          Text(userID.prefix(1).uppercased())
            .fontSize(avatarSize / 2)
//            .background(
//              RR(cornerRadius, .gray.opacity(0.5)).equatable()
//                .frame(width: avatarSize, height: avatarSize)
//            )
        }
      }
    }
    .frame(width: avatarSize, height: avatarSize)
    .mask(RR(cornerRadius, .black).equatable())
//    .drawingGroup()
    .background(SavedFlag(cornerRadius: cornerRadius, saved: saved).equatable())
  }
}


struct SavedFlag: View, Equatable {
  private let flagY: CGFloat = 16
  static func == (lhs: SavedFlag, rhs: SavedFlag) -> Bool {
    lhs.saved == rhs.saved && lhs.cornerRadius == rhs.cornerRadius
  }
  var cornerRadius: Double
  var saved: Bool
  var body: some View {
    ZStack {
      Image(systemName: "bookmark.fill")
        .foregroundColor(.green)
        .offset(y: saved ? flagY : 0)

      RR(cornerRadius, .gray).equatable()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .compositingGroup()
    .animation(.interpolatingSpring(stiffness: 150, damping: 12).delay(0.4), value: saved)
  }
}
