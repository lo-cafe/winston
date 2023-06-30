//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Posts: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
  
  var body: some View {
    NavigationView {
      List {
        if let subs = redditAPI.subs {
          ForEach(subs.sorted { $0.data.display_name.lowercased() < $1.data.display_name.lowercased() }, id: \.data.id) { item in
            NavigationLink {
              SubredditPosts(subreddit: item.data)
            } label: {
              HStack {
                ZStack {
                  let communityIcon = item.data.community_icon.split(separator: "?")
                  let icon = item.data.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : item.data.icon_img
                  AsyncImage(url: URL(string: icon)) { image in
                    image
                      .resizable()
                      .scaledToFill()
                      .frame(width: 25, height: 25)
                      .mask(Circle())
                  } placeholder: {
                    Text(item.data.display_name.prefix(1))
                      .frame(width: 25, height: 25)
                      .background(.blue, in: Circle())
                      .mask(Circle())
                  }
                }
              }
              Text(item.data.display_name)
            }
          }
        }
      }
      .refreshable {
        await redditAPI.fetchSubs()
      }
      .onAppear {
        Task {
          await redditAPI.fetchSubs()
        }
      }
      .navigationTitle("Subs")
      //        .onDelete(perform: deleteItems)
      //      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: {}) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
    }
  }
}

//struct Posts_Previews: PreviewProvider {
//  static var previews: some View {
//    Posts()
//  }
//}
