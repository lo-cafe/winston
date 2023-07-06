//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import SDWebImageSwiftUI

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

struct SubItem: View {
  var sub: Subreddit
  var body: some View {
    NavigationLink {
      SubredditPosts(subreddit: sub)
    } label: {
      if let data = sub.data {
        HStack {
          ZStack {
            let communityIcon = data.community_icon.split(separator: "?")
            let icon = data.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : data.icon_img
            if icon == "" {
              Text(data.display_name.prefix(1).uppercased())
                .frame(width: 30, height: 30)
                .background(Color.hex(data.primary_color), in: Circle())
                .mask(Circle())
                .fontSize(16, .semibold)
            } else {
              WebImage(url: URL(string: icon))
                .resizable()
                .placeholder {
                  ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 22, height: 22 )
                    .frame(width: 30, height: 30 )
                    .background(Color.hex(data.primary_color), in: Circle())
                }
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: 30, height: 30)
                .mask(Circle())
            }
          }
          Text(data.display_name)
        }
      } else {
        Text("Error")
      }
    }
  }
}

class SubsDictContainer: ObservableObject {
  @Published var data: [String: [Subreddit]]?
}

struct Subreddits: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
  @Default(.subreddits) var subreddits
  @State var searchText: String = ""
  @StateObject var subsDict = SubsDictContainer()
  
  func sort(_ subs: [ListingChild<SubredditData>]) -> [String: [Subreddit]] {
    return Dictionary(grouping: subs.compactMap { $0.data }, by: { String($0.display_name.prefix(1)).uppercased() })
      .mapValues { items in items.sorted { $0.display_name < $1.display_name }.map { Subreddit(data: $0, api: redditAPI) } }
  }
  
  var body: some View {
    GoodNavigator {
      List {
        if let subsDictData = subsDict.data {
          if searchText != "" {
            ForEach(Array(Array(subsDictData.values).flatMap { $0 }.filter { ($0.data?.display_name ?? "").lowercased().contains(searchText.lowercased()) }).sorted { ($0.data?.display_name.lowercased() ?? "") < ($1.data?.display_name.lowercased() ?? "") }, id: \.self.id) { sub in
              SubItem(sub: sub)
            }
          } else {
            Section(header: Text("FAVORITES")) {
              ForEach(Array(subsDictData.values).flatMap { $0 }.filter { $0.data?.user_has_favorited ?? false }.sorted { ($0.data?.display_name.lowercased() ?? "") < ($1.data?.display_name.lowercased() ?? "") }, id: \.self.id) { sub in
                SubItem(sub: sub)
              }
            }
            ForEach(Array(subsDictData.keys).sorted { $0 < $1 }, id: \.self) { letter in
              if let subs = subsDictData[letter] {
                Section(header: Text(letter)) {
                  ForEach(subs) { sub in
                    SubItem(sub: sub)
                  }
                }
              }
            }
          }
        }
      }
      .searchable(text: $searchText, prompt: "Search my subreddits")
      .refreshable {
        await redditAPI.fetchSubs()
      }
      .onAppear {
        if subsDict.data  == nil {
          if subreddits.count > 0 {
            subsDict.data = sort(subreddits)
          }
          
          Task {
            await redditAPI.fetchSubs()
          }
        }
      }
      .onChange(of: subreddits) { _ in
        withAnimation(nil) {
          subsDict.data = sort(subreddits)
        }
      }
      .navigationTitle("Subs")
      //        .onDelete(perform: deleteItems)
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
