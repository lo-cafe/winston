//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import NukeUI
import Nuke

struct AvatarView: View, Equatable {
  static func == (lhs: AvatarView, rhs: AvatarView) -> Bool {
    lhs.saved == rhs.saved && lhs.avatarImgRequest?.url == rhs.avatarImgRequest?.url && lhs.theme == rhs.theme && rhs.avatarSize == lhs.avatarSize
  }
  var saved: Bool
  var avatarImgRequest: ImageRequest?
  var userID: String
  var fullname: String? = nil
  var theme: AvatarTheme?
  var avatarSize: CGFloat?
  
  init(saved: Bool, avatarImgRequest: ImageRequest? = nil, userID: String, fullname: String? = nil, theme: AvatarTheme? = nil, avatarSize: CGFloat? = nil) {
    self.saved = saved
    self.avatarImgRequest = avatarImgRequest
    self.userID = userID
    self.fullname = fullname
    self.theme = theme
    self.avatarSize = avatarSize
  }  
  
  init(saved: Bool, url: URL?, userID: String, fullname: String? = nil, theme: AvatarTheme? = nil, avatarSize: CGFloat? = nil) {
    self.saved = saved
    self.avatarImgRequest = .init(url: url)
    self.userID = userID
    self.fullname = fullname
    self.theme = theme
    self.avatarSize = avatarSize
  }  
  
  init(saved: Bool, url: String, userID: String, fullname: String? = nil, theme: AvatarTheme? = nil, avatarSize: CGFloat? = nil) {
    self.saved = saved
    self.avatarImgRequest = .init(stringLiteral: url)
    self.userID = userID
    self.fullname = fullname
    self.theme = theme
    self.avatarSize = avatarSize
  }
  
  var body: some View {
    let avatarSize = avatarSize ?? theme?.size ?? 0
    let cornerRadius = (theme?.cornerRadius ?? (avatarSize / 2))
    Group {
      if userID == "[deleted]" {
        Image(systemName: "trash")
          .foregroundColor(.red)
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
    .background(RR(cornerRadius, .primary.opacity(0.15)).frame(avatarSize))
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
        .animation(.easeOut(duration: 0.15).delay(saved ? 0 : 0.5)) { $0.opacity(saved ? 1 : 0) }
        .animation(.interpolatingSpring(stiffness: 150, damping: 12).delay(0.4)) { $0.offset(y: saved ? flagY : 0) }
    }
  }
}
