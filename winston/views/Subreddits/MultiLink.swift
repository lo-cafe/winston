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
  
  
  var body: some View {
    Menu {
      if let subs = multi.data?.subreddits {
        ForEach(subs) { sub in
          if let data = sub.data {
            SubItemButton(selectedSub: $selectedSub, sub: Subreddit(data: data, api: RedditAPI.shared))
          }
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
        Text(multi.data?.display_name)
          .foregroundColor(.primary)
          .fontSize(15, .medium)
      }
      .multilineTextAlignment(.center)
      .contentShape(Rectangle())
    } primaryAction: {
      selectedSub = .multi(multi)
    }
  }
}
