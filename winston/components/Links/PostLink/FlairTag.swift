//
//  FlairTag.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct FlairTag: View {
  static let height: Double = 20

  var subredditIconKit: SubredditIconKit?
  var text: String
  var color: Color = .secondary
  var body: some View {
    HStack(spacing: 4) {
      if let subredditIconKit = subredditIconKit { SubredditIcon(subredditIconKit: subredditIconKit, size: 16) }
      Text(text)
        .padding(.vertical, 2)
    }
    .fontSize(13, subredditIconKit == nil ? .regular : .semibold)
    .padding(.leading, subredditIconKit == nil ? 9 : 0)
    .padding(.trailing, 9)
    .background(Capsule(style: .continuous).fill(color.opacity(0.2)))
    .foregroundColor(.primary.opacity(0.5))
    .frame(maxWidth: 150, alignment: .leading)
    .fixedSize(horizontal: true, vertical: false)
    .lineLimit(1)
    
  }
}
