//
//  FlairTag.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct FlairTag: View {
  static let height: Double = 20
  var data: SubredditData?
  var text: String
  var color: Color = .secondary
  var body: some View {
    HStack(spacing: 4) {
      if let data = data { SubredditIcon(data: data, size: 16) }
      Text(text)
        .padding(.vertical, 2)
    }
    .fontSize(13, data.isNil ? .regular : .semibold)
    .padding(.leading, data.isNil ? 9 : 0)
    .padding(.trailing, 9)
    .background(Capsule(style: .continuous).fill(color.opacity(0.2)))
    .foregroundColor(.primary.opacity(0.5))
    .frame(maxWidth: 150, alignment: .leading)
    .fixedSize(horizontal: true, vertical: false)
    .lineLimit(1)
  }
}
