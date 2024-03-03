//
//  PostReplyBG.swift
//  winston
//
//  Created by Igor Marcossi on 03/03/24.
//

import SwiftUI

struct PostReplyBG: View {
  var pos: CommentBGSide
  @Environment(\.useTheme) private var selectedTheme
    var body: some View {
      let theme = selectedTheme.comments
      Spacer()
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius * 2.0, maxHeight: theme.theme.cornerRadius * 2.0, alignment: .top)
        .background(CommentBG(cornerRadius: theme.theme.cornerRadius, pos: .bottom).fill(theme.theme.bg()))
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius, maxHeight: theme.theme.cornerRadius, alignment: .bottom)
        .clipped()
    }
}
