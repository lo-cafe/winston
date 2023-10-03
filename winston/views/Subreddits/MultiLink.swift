//
//  MultiLink.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Popovers

struct MultiLink: View {
  @Binding var selectedSub: FirstSelectable?
  @StateObject var multi: Multi
  @StateObject private var subs = NonObservableArray<Subreddit>()
  
  var body: some View {
    Menu {
      ForEach(subs.data) { sub in
        SubItemButton(selectedSub: $selectedSub, sub: sub)
      }
    } label: {
      VStack(spacing: 10) {
        if let imgLink = multi.data?.icon_url, let imgURL = URL(string: imgLink) {
          URLImage(url: imgURL)
            .scaledToFill()
            .frame(width: 72, height: 72)
            .mask(Circle())
        }
        Text(multi.data?.display_name)
          .foregroundColor(.primary)
          .fontSize(15, .medium)
      }
      .multilineTextAlignment(.center)
      .contentShape(Rectangle())
    } primaryAction: {
      selectedSub = .multi(multi)
    }
    .onAppear {
      if subs.data.count == 0 {
        subs.data = multi.data?.subreddits?.compactMap { sub in
          if let data = sub.data { return Subreddit(data: data, api: RedditAPI.shared) }
          return nil
        } ?? []
      }
    }
  }
}
