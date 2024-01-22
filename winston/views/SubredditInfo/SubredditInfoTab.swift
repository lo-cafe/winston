//
//  Info.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import SwiftUI

struct SubredditInfoTab: View {
  var subreddit: Subreddit
  @State var loading = true
    var body: some View {
      if let data = subreddit.data {
        HStack {
          
          DataBlock(icon: "person.3.fill", label: "Subscribers", value: "\(formatBigNumber(data.subscribers ?? 0))")
          DataBlock(icon: "app.connected.to.app.below.fill", label: "Online", value: loading ? "loading..." : "\(formatBigNumber(data.accounts_active ?? 0))")
          
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
          if loading {
            Task(priority: .background) {
              await subreddit.refreshSubreddit()
              loading = false
            }
          }
        }

        VStack {
          Text("Description")
            .fontSize(20, .bold)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          Text((data.public_description == "" ? data.description ?? "" : data.public_description).md())
          
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
      }
    }
}
