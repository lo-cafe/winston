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
  
  var body: some View {
    let avatarSize = avatarSize ?? theme?.size ?? 0
    AvatarRaw(saved: saved, avatarImgRequest: avatarRequest, userID: userID, fullname: fullname, theme: theme, avatarSize: avatarSize)
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
            RR(cornerRadius, .acceptablePrimary).equatable()
              .frame(width: avatarSize, height: avatarSize)
          )
      } else {
    if let avatarImgRequest = avatarImgRequest {
      ThumbReqImage(imgRequest: avatarImgRequest, size: CGSize(width: avatarSize, height: avatarSize))
        } else {
          Text(userID.prefix(1).uppercased())
            .fontSize(avatarSize / 2)
        }
      }
    }
    .frame(width: avatarSize, height: avatarSize)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
