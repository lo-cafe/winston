//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import Kingfisher
import Combine

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

struct SubItem: View {
  @Environment(\.editMode) var editMode
  var openSub: (Subreddit) -> ()
  @ObservedObject var sub: Subreddit
  var body: some View {
    if let data = sub.data {
      let favorite = data.user_has_favorited ?? false
      Button {
        openSub(sub)
      } label: {
        HStack {
          SubredditIcon(data: data)
          Text(data.display_name ?? "")
            .foregroundColor(.primary)
          
          Spacer()
          
          Image(systemName: "star.fill")
            .foregroundColor(favorite ? .blue : .secondary.opacity(0.35))
            .highPriorityGesture(
              TapGesture()
                .onEnded {
                  Task {
                    await sub.favoriteToggle()
                  }
                }
            )
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.automatic)
    } else {
      Text("Error")
    }
  }
}

struct SubredditBigBtn: View {
  var openSub: (Subreddit) -> ()
  var icon: String
  var iconColor: Color
  var label: String
  var destination: Subreddit
  var body: some View {
    Button {
      openSub(destination)
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .fontSize(32)
          .foregroundColor(iconColor)
        Text(label)
          .fontSize(17, .semibold)
          .foregroundColor(.primary)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(RR(13, .listBG))
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(.plain)
  }
}

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
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
  @Default(.subreddits) var subreddits
  @State var searchText: String = ""
  @StateObject var subsDict = SubsDictContainer()
  @StateObject var selectedSubreddit = SelectedSubredditContainer()
  @State var selectedSubActive = false
  @State var loaded = false
  @State var editMode: EditMode = .inactive
  
  func sort(_ subs: [ListingChild<SubredditData>]) -> [String: [Subreddit]] {
    return Dictionary(grouping: subs.compactMap { $0.data }, by: { String($0.display_name?.prefix(1) ?? "").uppercased() })
      .mapValues { items in items.sorted { ($0.display_name ?? "") < ($1.display_name ?? "") }.map { Subreddit(data: $0, api: redditAPI) } }
  }
  
  func openSub(_ sub: Subreddit) {
    selectedSubreddit.sub = sub
    selectedSubActive = true
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
    GoodNavigator {
      List {
        HStack(spacing: 12) {

          SubredditBigBtn(openSub: openSub, icon: "house.circle.fill", iconColor: .blue, label: "Home", destination: Subreddit(id: "home", api: redditAPI))

          SubredditBigBtn(openSub: openSub, icon: "bookmark.circle.fill", iconColor: .green, label: "Saved", destination: Subreddit(id: "home", api: redditAPI))

        }
        .frame(maxWidth: .infinity)
        .id("upperPart")
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listStyle(.plain)
        .onChange(of: subreddits) { val in
          withAnimation(nil) {
            subsDict.data = sort(val)
          }
        }
//
        if searchText != "" {
          ForEach(Array(subsArr.filter { ($0.data?.display_name ?? "").lowercased().contains(searchText.lowercased()) }).sorted { ($0.data?.display_name?.lowercased() ?? "") < ($1.data?.display_name?.lowercased() ?? "") }, id: \.self.id) { sub in
            SubItem(openSub: openSub, sub: sub)
          }
        } else {
          Section("FAVORITES") {
            ForEach(favoritesArr, id: \.self.id) { sub in
              SubItem(openSub: openSub, sub: sub)
            }
            .onDelete(perform: deleteFromFavorites)
          }
          ForEach(listArr, id: \.self) { letter in
            if let subs = subsDictData[letter] {
              Section(header: Text(letter)) {
                ForEach(subs) { sub in
                  SubItem(openSub: openSub, sub: sub)
                }
                .onDelete(perform: { i in deleteFromList(at: i, letter: letter)})
              }
            }
          }
        }
      }
      .background(
        NavigationLink(destination: SubredditPosts(subreddit: selectedSubreddit.sub), isActive: $selectedSubActive, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
      )
      .searchable(text: $searchText, prompt: "Search my subreddits")
      .refreshable {
        await redditAPI.fetchSubs()
      }
      .navigationTitle("Subs")
      .onChange(of: reset) { _ in selectedSubActive = false }
      .onAppear {
        if !loaded {
          if subreddits.count > 0 {
            subsDict.data = sort(subreddits)
            loaded = true
          }
          
          Task {
            await redditAPI.fetchSubs()
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
      }
      .environment(\.editMode, $editMode)
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
