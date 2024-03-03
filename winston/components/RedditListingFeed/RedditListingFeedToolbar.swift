//
//  RedditListingFeedToolbar.swift
//  winston
//
//  Created by Igor Marcossi on 03/03/24.
//

import SwiftUI

struct RedditListingFeedToolbar<S: Sorting>: View {
  var itemsManager: FeedItemsManager<S>
  var subreddit: Subreddit?
  var body: some View {
    HStack {
      if let currSort = itemsManager.sorting {
        Menu {
          ForEach(Array(S.allCases), id: \.self) { opt in
            if let children = opt.meta.children {
              Menu {
                ForEach(children, id: \.self.meta.apiValue) { child in
                  if let val = child.valueWithParent as? S {
                    Button(child.meta.label, systemImage: child.meta.icon) {
                      itemsManager.sorting = val
                    }
                  }
                }
              } label: {
                Label(opt.meta.label, systemImage: opt.meta.icon)
              }
            } else {
              Button(opt.meta.label, systemImage: opt.meta.icon) {
                itemsManager.sorting = opt
              }
            }
          }
        } label: {
          Image(systemName: currSort.meta.icon)
            .foregroundColor(Color.accentColor)
            .fontSize(17, .bold)
        }
      }
      //          .disabled(subreddit.id == "saved")
      //        }
      if let sub = subreddit, let data = sub.data {
        Button {
          Nav.to(.reddit(.subInfo(sub)))
        } label: {
          SubredditIcon(subredditIconKit: data.subredditIconKit)
        }
      }
    }
  }
}
