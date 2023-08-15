//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import Combine
import SimpleHaptics

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

class SubsDictContainer: ObservableObject {
  @Published var data: [String: [Subreddit]] = [:]
  
//  var cancellables = [AnyCancellable]()
//
//  init() {
//    self.observeChildrenChanges()
//  }
//
//  func observeChildrenChanges() {
//    cancellables.forEach { cancelable in
//      cancelable.cancel()
//    }
//    Array(data.values).flatMap { $0 }.forEach({
//      let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
//      self.cancellables.append(c)
//    })
//  }
}

struct Subreddits: View {
  var reset: Bool
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
//  @State private var subreddits: [ListingChild<SubredditData>] = Defaults[.subreddits]
  @Default(.subreddits) private var subreddits
  @State private var searchText: String = ""
  @StateObject private var subsDict = SubsDictContainer()
  @State private var loaded = false
  @State private var subsArr: [Subreddit] = []
  @State private var favoritesArr: [Subreddit] = []
  @State private var availableLetters: [String] = []
  @StateObject private var router = Router()
  
  @Default(.preferenceDefaultFeed) var preferenceDefaultFeed // handle default feed selection routing
  
  func sort(_ subs: [ListingChild<SubredditData>]) -> [String: [Subreddit]] {
    return Dictionary(grouping: subs.compactMap { $0.data }, by: { String($0.display_name?.prefix(1) ?? "").uppercased() })
      .mapValues { items in items.sorted { ($0.display_name ?? "") < ($1.display_name ?? "") }.map { Subreddit(data: $0, api: redditAPI) } }
  }
  
  func setArrays(_ val: [ListingChild<SubredditData>]) {
    Task(priority: .background) {
      let newSubsDict = sort(val)
      let newSubsArr = Array(newSubsDict.values).flatMap { $0 }
      let newFavoritesArr = Array(newSubsArr.filter { $0.data?.user_has_favorited ?? false }).sorted { ($0.data?.display_name?.lowercased() ?? "") < ($1.data?.display_name?.lowercased() ?? "") }
      let newAvailableLetters = Array(newSubsDict.keys).sorted { $0 < $1 }
      await MainActor.run {
        withAnimation(.default) {
          subsDict.data = newSubsDict
          subsArr = newSubsArr
          favoritesArr = newFavoritesArr
          availableLetters = newAvailableLetters
        }
      }
    }
  }
  
  var body: some View {
    let subsDictData = subsDict.data
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
          
          
          if searchText != "" {
            Section("Found subs") {
              ForEach(Array(subsArr.filter { ($0.data?.display_name ?? "").lowercased().contains(searchText.lowercased()) }).sorted { ($0.data?.display_name?.lowercased() ?? "") < ($1.data?.display_name?.lowercased() ?? "") }, id: \.self.id) { sub in
                SubItem(sub: sub)
              }
            }
          } else {
            Section("Favorites") {
              ForEach(favoritesArr, id: \.self.id) { sub in
                SubItem(sub: sub)
              }
              .onDelete(perform: deleteFromFavorites)
            }
            ForEach(availableLetters, id: \.self) { letter in
              if let subs = subsDictData[letter] {
                Section(header: Text(letter)) {
                  ForEach(subs) { sub in
                    SubItem(sub: sub)
                      .id("\(sub.id)-main")
                  }
                  .onDelete(perform: { i in deleteFromList(at: i, letter: letter)})
                }
              }
            }
          }
        }
        .scrollIndicators(.hidden)
        .listStyle(.sidebar)
        .scrollDismissesKeyboard(.immediately)
        .loader(!loaded && subreddits.count == 0)
        .background(OFWOpener())
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
          _ = await redditAPI.fetchSubs()
        }
        .onChange(of: subreddits) { val in
          setArrays(val)
        }
        .navigationTitle("Subs")
        .onAppear {
          if !loaded {
            if subreddits.count > 0 {
              setArrays(subreddits)
//              subsDict.data = sort(subreddits)
            }
            Task(priority: .background) {
              // MARK: Route to default feed
              if preferenceDefaultFeed != "subList" && router.path.count == 0 { // we are in subList, can ignore
                let tempSubreddit = Subreddit(id: preferenceDefaultFeed, api: redditAPI)
                router.path.append(SubViewType.posts(tempSubreddit))
              }
              
              _ = await redditAPI.fetchSubs()
              withAnimation {
                loaded = true
              }
            }
          }
        }
        .onChange(of: reset) { _ in
          router.path.removeLast(router.path.count)
        }
        .defaultNavDestinations(router)
      }
      //        .onDelete(perform: deleteItems)
    }
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
