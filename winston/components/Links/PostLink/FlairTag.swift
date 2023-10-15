//
//  FlairTag.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI
import Defaults

struct FlairTag: View {
  static let height: Double = 20
  var id: String?
  var data: SubredditData?
  var text: String
  var color: Color = .secondary
  var body: some View {
    HStack(spacing: 4) {
      if let data = data {
        SubredditIcon(data: data, size: 16)
      } else if let savedIcon = Defaults[.subredditIcons][id ?? ""] {
        if let iconImg = savedIcon["icon_img"], iconImg!.count > 0 {
          SubredditIcon(iconImg: iconImg, size: 16)
        } else if let communityIcon = savedIcon["community_icon"], communityIcon!.count > 0 {
          SubredditIcon(communityIcon: communityIcon, size: 16)
        }
      }
      
      Text(text)
        .padding(.vertical, 2)
    }
    .fontSize(13, data == nil ? .regular : .semibold)
    .padding(.leading, data == nil ? 9 : 0)
    .padding(.trailing, 9)
    .background(Capsule(style: .continuous).fill(color.opacity(0.2)))
    .foregroundColor(.primary.opacity(0.5))
    .frame(maxWidth: 150, alignment: .leading)
    .fixedSize(horizontal: true, vertical: false)
    .lineLimit(1)
  }
}
