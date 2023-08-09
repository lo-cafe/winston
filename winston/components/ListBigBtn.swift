//
//  ListBigBtn.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import SwiftUI

struct ListBigBtn: View {
  @EnvironmentObject private var router: Router
  var icon: String
  var iconColor: Color
  var label: String
  var destination: Subreddit
  var body: some View {
    Button {
      router.path.append(SubViewType.posts(destination))
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .fontSize(32)
          .foregroundColor(iconColor)
        Text(label)
          .fontSize(17, .semibold)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundColor(.primary)
      .background(RR(13, .listBG))
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(.plain)
  }
}
