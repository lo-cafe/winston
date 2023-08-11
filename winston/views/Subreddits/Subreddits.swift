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
  @Published var data: [String: [Subreddit]] = [:] {
    didSet { observeChildrenChanges() }
  }
  var cancellables = [AnyCancellable]()
  
  init() {
    self.observeChildrenChanges()
  }
  
  func observeChildrenChanges() {
    cancellables.forEach { cancelable in
      cancelable.cancel()
    }
    Array(data.values).flatMap { $0 }.forEach({
      let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
      self.cancellables.append(c)
    })
  }
}

class SelectedSubredditContainer: ObservableObject {
  @Published var sub = Subreddit(id: "home", api: RedditAPI())
}

struct Subreddits: View {
  var reset: Bool
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
  @Default(.subreddits) private var subreddits
  @Default(.openHomeSubOnLaunch) private var openHomeSubOnLaunch
  @State private var searchText: String = ""
  @StateObject private var subsDict = SubsDictContainer()
  @State private var loaded = false
  @State private var editMode: EditMode = .inactive
  @StateObject private var router = Router()
  @State private var scrollLetter = "A"
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  
  @Default(.preferenceDefaultFeed) var preferenceDefaultFeed // handle default feed selection routing
  
  func sort(_ subs: [ListingChild<SubredditData>]) -> [String: [Subreddit]] {
    return Dictionary(grouping: subs.compactMap { $0.data }, by: { String($0.display_name?.prefix(1) ?? "").uppercased() })
      .mapValues { items in items.sorted { ($0.display_name ?? "") < ($1.display_name ?? "") }.map { Subreddit(data: $0, api: redditAPI) } }
  }
  
  var subsArr: [Subreddit] {
    return Array(subsDict.data.values).flatMap { $0 }
  }
  
  var favoritesArr: [Subreddit] {
    return Array(subsArr.filter { $0.data?.user_has_favorited ?? false }).sorted { ($0.data?.display_name?.lowercased() ?? "") < ($1.data?.display_name?.lowercased() ?? "") }
  }
  
  var listArr: [String] {
    return Array(subsDict.data.keys).sorted { $0 < $1 }
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
            ForEach(listArr, id: \.self) { letter in
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
        .navigationTitle("Subs")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
        }
        .overlay(
          VStack(spacing: 2) {
            ForEach(listArr, id: \.self) { letter in
              if subsDictData[letter] != nil {
                Text(letter.uppercased())
                  .contentShape(Rectangle())
                  .highPriorityGesture(TapGesture().onEnded { scrollLetter = letter })
              }
            }
          }
            .padding(.trailing, 2)
            .frame(width: 16, alignment: .trailing)
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .contentShape(Rectangle())
            .highPriorityGesture(
              DragGesture()
                .onChanged { val in
                  let stepI = Int(val.location.y / 15.3)
                  if stepI >= listArr.count || stepI < 0 { return }
                  let newLetter = listArr[stepI]
                  if newLetter != scrollLetter {
                    withAnimation {
                      scrollLetter = newLetter
                    }
                  }
                }
            )
            .frame(height: UIScreen.screenHeight, alignment: .trailing)
            .ignoresSafeArea()
            .fontSize(11, .semibold)
            .foregroundColor(.blue)
          , alignment: .trailing
        )
        .onChange(of: scrollLetter) { x in
          try? haptics.fire(intensity: 0.5, sharpness: 0.5)
          if let id = subsDictData[x]?[0].id {
            withAnimation(.interactiveSpring()) {
              proxy.scrollTo("\(id)-main", anchor: .top)
            }
          }
          
          // MARK: Route to default feed
          if preferenceDefaultFeed != "subList" { // we are in subList, can ignore
            let tempSubreddit = Subreddit(id: preferenceDefaultFeed, api: redditAPI)
            router.path.append(SubViewType.posts(tempSubreddit))
          }
        }
        .refreshable {
          Task {
            await updatePostsInBox(redditAPI, force: true)
          }
          await redditAPI.fetchSubs()
        }
        .onChange(of: subreddits) { val in
          withAnimation(nil) {
            subsDict.data = sort(val)
          }
        }
        .onAppear {
          if !loaded {
            if subreddits.count > 0 {
              subsDict.data = sort(subreddits)
            }
            Task {
              if openHomeSubOnLaunch && router.path.count == 0 { router.path.append(SubViewType.posts(Subreddit(id: "home", api: redditAPI))) }
              await redditAPI.fetchSubs()
              withAnimation {
                loaded = true
              }
            }
          }
        }
        .onChange(of: reset) { _ in
          router.path = NavigationPath()
        }
        .defaultNavDestinations(router)
        .environment(\.editMode, $editMode)
      }
      //        .onDelete(perform: deleteItems)
    }
  }
  
  func deleteFromFavorites(at offsets: IndexSet) {
    for i in offsets {
      Task {
        await favoritesArr[i].subscribeToggle(optimistic: true)
      }
    }
  }
  
  func deleteFromList(at offsets: IndexSet, letter: String) {
    for i in offsets {
      if let sub = subsDict.data[letter]?[i] {
        Task {
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
