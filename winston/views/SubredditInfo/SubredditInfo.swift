//
//  SubredditInfo.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import SwiftDate
import Defaults
import AlertToast

enum SubInfoTabs: String, CaseIterable, Identifiable {
  var id: Self {
    return self
  }
  
  case info = "Info"
  case rules = "Rules"
  case myposts = "My posts"
}

struct SubredditInfo: View {
  @ObservedObject var subreddit: Subreddit

  @State private var selectedTab: SubInfoTabs = .info
  
  @StateObject private var myPosts = ObservableArray<Post>()
  @State private var myPostsLoaded = false
  @State private var addedToFavs = false
  @Default(.likedButNotSubbed) var likedButNotSubbed
  var body: some View {
    let isliked = likedButNotSubbed.contains(subreddit)
    List {
      Group {
        if let data = subreddit.data {
          VStack(spacing: 12) {
            SubredditIcon(data: data, size: 125)
            
            VStack {
              Text("r/\(data.display_name ?? "")")
                .fontSize(22, .bold)
              Text("Created \(data.created.isNil ? "at some point" : Date(timeIntervalSince1970: TimeInterval(data.created!)).toFormat("MMM dd, yyyy"))")
                .fontSize(16, .medium)
                .opacity(0.5)
              HStack{
                SubscribeButton(subreddit: subreddit)
                
              }
            }
            .toast(isPresenting: $addedToFavs){
              AlertToast(displayMode: .hud, type: .systemImage("star.fill", Color.blue), title: "Added to Favorites")
            }
            
            Picker("", selection: $selectedTab) {
              ForEach(SubInfoTabs.allCases) { tab in
                Text(tab.rawValue)
              }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
          }
          .id("header")
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
          .toolbar{
            ToolbarItem(){
              Button{
                Task{
                  if !data.user_has_favorited! {
                    let liked = subreddit.localFavoriteToggle()
                    if liked {
                      addedToFavs.toggle()
                    }
                  } else {
                    await subreddit.favoriteToggle()
                  }
                }
              } label: {
                Label("Favorites", systemImage: (isliked || data.user_has_favorited!) ? "star.fill" : "star")
                  .foregroundColor(.blue)
                  .labelStyle(.iconOnly)
              }
            }
          }
            
            switch selectedTab {
            case .info:
              SubredditInfoTab(subreddit: subreddit)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            case .myposts:
              SubredditMyPostsTab()
            case .rules:
              SubredditRulesTab(subreddit: subreddit)
            }
        }
      }
      .listRowSeparator(.hidden)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}
//
//struct SubredditInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        SubredditInfo()
//    }
//}
