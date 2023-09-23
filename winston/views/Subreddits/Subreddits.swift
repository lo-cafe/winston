//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import Combine

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

class SubsDictContainer: ObservableObject {
  @Published var data: [String: [Subreddit]] = [:]
}


struct Subreddits: View, Equatable {
  static func == (lhs: Subreddits, rhs: Subreddits) -> Bool {
    return lhs.loaded == rhs.loaded
  }
  var loaded: Bool
  @StateObject var routerProxy: RouterProxy
  @Environment(\.managedObjectContext) private var context
  
  @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var subreddits: FetchedResults<CachedSub>
  @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var multis: FetchedResults<CachedMulti>
  @State private var searchText: String = ""
  @StateObject private var subsDict = SubsDictContainer()
  @State private var favoritesArr: [Subreddit] = []
  
  @Default(.likedButNotSubbed) var likedButNotSubbed // subreddits that a user likes but is not subscribed to so they wont be in subsDict
  @Default(.disableAlphabetLettersSectionsInSubsList) var disableAlphabetLettersSectionsInSubsList
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  
  var sections: [String:[CachedSub]] {
    return Dictionary(grouping: subreddits.filter({ $0.user_is_subscriber })) { sub in
      return String((sub.display_name ?? "a").first!.uppercased())
    }
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      List {
        if searchText == "" {
          VStack(spacing: 12) {
            HStack(spacing: 12) {
              ListBigBtn(icon: "house.circle.fill", iconColor: .blue, label: "Home", destination: Subreddit(id: "home", api: RedditAPI.shared))
              
              ListBigBtn(icon: "chart.line.uptrend.xyaxis.circle.fill", iconColor: .red, label: "Popular", destination: Subreddit(id: "popular", api: RedditAPI.shared))
            }
            HStack(spacing: 12) {
              ListBigBtn(icon: "signpost.right.and.left.circle.fill", iconColor: .orange, label: "All", destination: Subreddit(id: "all", api: RedditAPI.shared))
              
              ListBigBtn(icon: "bookmark.circle.fill", iconColor: .green, label: "Saved", destination: Subreddit(id: "saved", api: RedditAPI.shared))
                .opacity(0.5).allowsHitTesting(false)
            }
          }
          .frame(maxWidth: .infinity)
          .id("bigButtons")
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          
          
          PostsInBoxView()
            .scrollIndicators(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
          
          if multis.count > 0 {
            Section("Multis") {
              ScrollView(.horizontal) {
                HStack(spacing: 16) {
                  ForEach(multis) { multi in
                    MultiLink(multi: MultiData(entity: multi), routerProxy: routerProxy)
                  }
                }
                .padding(.horizontal, 16)
              }
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listRowBackground(Color.clear)
          }
        }
        
        Group {
          if searchText != "" {
            Section("Found subs") {
              ForEach(Array(subreddits.filter { ($0.display_name ?? "").lowercased().contains(searchText.lowercased()) }), id: \.self.uuid) { cachedSub in
                SubItem(routerProxy: routerProxy, sub: Subreddit(data: SubredditData(entity: cachedSub), api: RedditAPI.shared), cachedSub: cachedSub)
                  .equatable()
              }
            }
          } else {
            let favs = subreddits.filter { $0.user_has_favorited && $0.user_is_subscriber }
            if favs.count > 0 {
              Section("Favorites") {
                ForEach(favs.sorted(by: { x, y in
                  (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a")
                }), id: \.self) { cachedSub in
                  SubItem(routerProxy: routerProxy, sub: Subreddit(data: SubredditData(entity: cachedSub), api: RedditAPI.shared), cachedSub: cachedSub)
                    .equatable()
                    .id("\(cachedSub.uuid ?? "")-fav")
                }
                .onDelete(perform: deleteFromFavorites)
              }
            }
            
            if disableAlphabetLettersSectionsInSubsList {
              
              Section("Subs") {
                ForEach(subreddits.filter({ $0.user_is_subscriber }).sorted(by: { x, y in
                  (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a")
                })) { cachedSub in
                  SubItem(routerProxy: routerProxy, sub: Subreddit(data: SubredditData(entity: cachedSub), api: RedditAPI.shared), cachedSub: cachedSub)
                    .equatable()
                }
              }
              
            } else {
              
              ForEach(sections.keys.sorted(), id: \.self) { letter in
                Section(header: Text(letter)) {
                  if let arr = sections[letter] {
                    ForEach(arr.sorted(by: { x, y in
                      (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a")
                    }), id: \.self.uuid) { cachedSub in
                      SubItem(routerProxy: routerProxy, sub: Subreddit(data: SubredditData(entity: cachedSub), api: RedditAPI.shared), cachedSub: cachedSub)
                        .equatable()
                    }
                    .onDelete(perform: { i in
                      deleteFromList(at: i, letter: letter)
                    })
                  }
                }
              }
              
            }
            
            
            
          }
        }
        .themedListDividers()
      }
      .environmentObject(routerProxy)
      .themedListBG(selectedTheme.lists.bg)
      .scrollIndicators(.hidden)
      .listStyle(.sidebar)
      .scrollDismissesKeyboard(.immediately)
      .loader(!loaded && subreddits.count == 0)
      .searchable(text: $searchText, prompt: "Search my subreddits")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
      }
      .overlay(
        AlphabetJumper(letters: sections.keys.sorted(), proxy: proxy)
        , alignment: .trailing
      )
      .refreshable {
        Task(priority: .background) {
          await updatePostsInBox(RedditAPI.shared, force: true)
        }
        Task(priority: .background) {
          _ = await RedditAPI.shared.fetchMyMultis()
        }
        _ = await RedditAPI.shared.fetchSubs()
      }
      .navigationTitle("Subs")
    }
  }
  
  func deleteFromFavorites(at offsets: IndexSet) {
    for i in offsets {
      Task(priority: .background) {
        favoritesArr[i].subscribeToggle(optimistic: true)
      }
    }
  }
  
  func deleteFromList(at offsets: IndexSet, letter: String) {
    for i in offsets {
      if let sub = subsDict.data[letter]?[i] {
        Task(priority: .background) {
          sub.subscribeToggle(optimistic: true)
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
