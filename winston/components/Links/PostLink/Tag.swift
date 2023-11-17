//
//  Tag.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI
import Defaults

struct Tag: View {
  static let height: Double = 15.6

  var subredditIconKit: SubredditIconKit?
  var text: String
  var color: Color = .secondary
  var fontSize: Double? = nil
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    HStack(spacing: 4) {
      if let subredditIconKit = subredditIconKit { SubredditIcon(subredditIconKit: subredditIconKit, size: 16) }
      Text(text)
        .padding(.vertical, 2)
    }
    .fontSize(fontSize ?? 13, .semibold)
    .padding(.leading, subredditIconKit == nil ? 9 : 0)
    .padding(.trailing, (fontSize ?? 13) * 0.7)
    .background(Capsule(style: .continuous).fill(theme.general.accentColor.cs(cs).color().opacity(0.2)))
    .foregroundColor(.primary.opacity(0.5))
    .frame(height: fontSize == nil ? Tag.height : nil, alignment: .leading)
    .fixedSize(horizontal: true, vertical: false)
    .lineLimit(1)
    
  }
}
