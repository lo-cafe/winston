//
//  ListBigBtn.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import SwiftUI

struct ListBigBtn: View {
  var openSub: (Subreddit) -> ()
  var icon: String
  var iconColor: Color
  var label: String
  var destination: Subreddit
  var selected: Bool
  var body: some View {
    Button {
      openSub(destination)
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .fontSize(32)
          .foregroundColor(selected ? .white : iconColor)
        Text(label)
          .fontSize(17, .semibold)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundColor(selected ? .white : .primary)
      .background(RR(13, selected ? IPAD ? .blue : .secondary : IPAD ? .secondary.opacity(0.2) : .listBG))
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(.plain)
  }
}