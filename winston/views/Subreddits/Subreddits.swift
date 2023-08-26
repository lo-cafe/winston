//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import Combine
import Shallows

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

class SubsDictContainer: ObservableObject {
  @Published var data: [String: [Subreddit]] = [:]
}


struct Subreddits: View {
  var reset: Bool
  @Environment(\.managedObjectContext) private var context
  @ObservedObject var router: Router
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
  @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var subreddits: FetchedResults<CachedSub>
  @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var multis: FetchedResults<CachedMulti>
  @State private var searchText: String = ""
  @StateObject private var subsDict = SubsDictContainer()
  @State private var loaded = false
  @State private var subsArr: [Subreddit] = []
  @State private var favoritesArr: [Subreddit] = []
  @State private var availableLetters: [String] = []
  
  @Default(.preferenceDefaultFeed) var preferenceDefaultFeed // handle default feed selection routing
  @Default(.likedButNotSubbed) var likedButNotSubbed // subreddits that a user likes but is not subscribed to so they wont be in subsDict
  
  var sections: [String:[CachedSub]] {
    return Dictionary(grouping: Array(subreddits)) { sub in
      return String((sub.display_name ?? "a").first!.uppercased())
    }
  }
  
  var body: some View {
//    let groupedMultisCache = Dictionary(grouping: multis) { $0.display_name.prefix(1) }
//    let groupedSubsCache = Dictionary(grouping: subreddits) { $0.display_name?.prefix(1) }

//    let subsDictData = subsDict.data
    NavigationStack(path: $router.path) {
      ScrollViewReader { proxy in
        List {
          if searchText == "" {
            VStack(spacing: 12) {
              HStack(spacing: 12) {
                ListBigBtn(icon: "house.circle.fill", iconColor: .blue, label: "Home", destination: Subreddit(id: "home", api: redditAPI))

                ListBigBtn(icon: "chart.line.uptrend.xyaxis.circle.fill", iconColor: .red, label: "Popular", destination: Subreddit(id: "popular", api: redditAPI))
              }
              HStack(spacing: 12) {
                ListBigBtn(icon: "signpost.right.and.left.circle.fill", iconColor: .orange, label: "All", destination: Subreddit(id: "all", api: redditAPI))

                ListBigBtn(icon: "bookmark.circle.fill", iconColor: .green, label: "Saved", destination: Subreddit(id: "saved", api: redditAPI))
                  .opacity(0.5).allowsHitTesting(false)
              }
            }
            .frame(maxWidth: .infinity)
            .id("bigButtons")
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }


          PostsInBoxView(someOpened: router.path.count > 0)
            .scrollIndicators(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)

          if multis.count > 0 {
            Section("Multis") {
              ScrollView(.horizontal) {
                HStack(spacing: 16) {
                  ForEach(multis) { multi in
                    MultiLink(multi: MultiData(entity: multi), router: router)
                  }
                }
                .padding(.horizontal, 16)
              }
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listRowBackground(Color.clear)
          }
          
          if searchText != "" {
            Section("Found subs") {
              ForEach(Array(subreddits.filter { ($0.display_name ?? "").lowercased().contains(searchText.lowercased()) }), id: \.self.id) { cachedSub in
                SubItem(sub: Subreddit(data: SubredditData(entity: cachedSub), api: redditAPI), cachedSub: cachedSub)
              }
            }
          } else {
            Section("Favorites") {
              ForEach(subreddits.filter { $0.user_has_favorited }, id: \.self.id) { cachedSub in
                  SubItem(sub: Subreddit(data: SubredditData(entity: cachedSub), api: redditAPI), cachedSub: cachedSub)
              }
              .onDelete(perform: deleteFromFavorites)
            }

            ForEach(sections.keys.sorted(), id: \.self) { letter in
              Section(header: Text(letter)) {
                if let arr = sections[letter] {
                  ForEach(arr) { cachedSub in
                    SubItem(sub: Subreddit(data: SubredditData(entity: cachedSub), api: redditAPI), cachedSub: cachedSub)
                  }
                  .onDelete(perform: deleteFromList)
                }
              }
            }
            
          }
        }
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
          AlphabetJumper(letters: availableLetters, proxy: proxy)
          , alignment: .trailing
        )
        .refreshable {
          Task(priority: .background) {
            await updatePostsInBox(redditAPI, force: true)
          }
          Task(priority: .background) {
            _ = await redditAPI.fetchMyMultis()
          }
          _ = await redditAPI.fetchSubs()
        }
        .navigationTitle("Subs")
        .task {
          if !loaded {
            // MARK: Route to default feed
            if preferenceDefaultFeed != "subList" && router.path.count == 0 { // we are in subList, can ignore
              let tempSubreddit = Subreddit(id: preferenceDefaultFeed, api: redditAPI)
              router.path.append(SubViewType.posts(tempSubreddit))
            }

            _ = await redditAPI.fetchSubs()
            _ = await redditAPI.fetchMyMultis()
            withAnimation {
              loaded = true
            }
          }
        }
        .onChange(of: reset) { _ in
          router.path.removeLast(router.path.count)
        }
      }
      .defaultNavDestinations(router)
//      .onDelete(perform: deleteItems)
    }
    .swipeAnywhere(router: router)
    .animation(.default, value: router.path)
  }
  
  func deleteFromFavorites(at offsets: IndexSet) {
    for i in offsets {
      Task(priority: .background) {
        await favoritesArr[i].subscribeToggle(optimistic: true)
      }
    }
  }
  
  func deleteFromList(at offsets: IndexSet, letter: String) {
    for i in offsets {
      if let sub = subsDict.data[letter]?[i] {
        Task(priority: .background) {
          await sub.subscribeToggle(optimistic: true)
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
