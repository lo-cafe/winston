//
//  MultiLink.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Popovers

struct MultiLink: View {
  var multi: Multi
  @State private var subs: [Subreddit] = []
  
  var body: some View {
    Menu {
      ForEach(subs) { sub in
        if let data = sub.data {
          SubItemButton(data: data, action: { Nav.to(.reddit(.subFeed(sub))) })
        }
      }
    } label: {
      VStack(spacing: 10) {
        if let imgLink = multi.data?.icon_url, let imgURL = URL(string: imgLink) {
          URLImage(url: imgURL)
            .scaledToFill()
            .frame(width: 72, height: 72)
            .mask(Circle())
        }
        Text(multi.data?.display_name ?? "")
          .foregroundColor(.primary)
          .fontSize(15, .medium)
      }
      .multilineTextAlignment(.center)
      .contentShape(Rectangle())
    } primaryAction: {
      Nav.to(.reddit(.multiFeed(multi)))
    }
    .onAppear {
      if subs.count == 0 {
        subs = multi.data?.subreddits?.compactMap { sub in
          if let data = sub.data { return Subreddit(data: data) }
          return nil
        } ?? []
      }
    }
  }
}
