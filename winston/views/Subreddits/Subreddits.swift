//
//  Posts.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import Combine
import SwiftDate
import Shiny

let alphabetLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

struct Subreddits: View, Equatable {
  static func == (lhs: Subreddits, rhs: Subreddits) -> Bool {
    return lhs.loaded == rhs.loaded && lhs.selectedSub == rhs.selectedSub && lhs.currentCredentialID == rhs.currentCredentialID
  }
  @Binding var selectedSub: Router.NavDest?
  var loaded: Bool
  var currentCredentialID: UUID
  init(selectedSub: Binding<Router.NavDest?>, loaded: Bool, currentCredentialID: UUID) {
    self.currentCredentialID = currentCredentialID
    self._selectedSub = selectedSub
    self.loaded = loaded
    self._subreddits = FetchRequest<CachedSub>(sortDescriptors: [NSSortDescriptor(key: "display_name", ascending: true)], predicate: NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg), animation: .default)
    self._multis = FetchRequest<CachedMulti>(sortDescriptors: [NSSortDescriptor(key: "display_name", ascending: true)], predicate: NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg), animation: .default)
  }
  
  @FetchRequest private var subreddits: FetchedResults<CachedSub>
  @FetchRequest private var multis: FetchedResults<CachedMulti>
  
  @State private var searchText: String = ""
  @State private var favoritesArr: [Subreddit] = []
  
  @Default(.likedButNotSubbed) private var likedButNotSubbed // subreddits that a user likes but is not subscribed to so they wont be in subsDict
  @Default(.disableAlphabetLettersSectionsInSubsList) private var disableAlphabetLettersSectionsInSubsList
  @Environment(\.managedObjectContext) private var context
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  
  @Default(.showingUpsellDict) var showingUpsellDict
  
  var sections: [String:[CachedSub]] {
    return Dictionary(grouping: subreddits.filter({ $0.user_is_subscriber })) { sub in
      return String((sub.display_name ?? "a").first!.uppercased())
    }
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      List(selection: $selectedSub) {
        if searchText == "" {
          VStack(spacing: 12) {
            HStack(spacing: 12) {
              ListBigBtn(selectedSub: $selectedSub, icon: "house.circle.fill", iconColor: .blue, label: "Home") {
                selectedSub = .reddit(.subFeed(Subreddit(id: "home")))
              }

              ListBigBtn(selectedSub: $selectedSub, icon: "chart.line.uptrend.xyaxis.circle.fill", iconColor: .red, label: "Popular") {
                selectedSub = .reddit(.subFeed(Subreddit(id: "popular")))
              }
            }
            HStack(spacing: 12) {
              ListBigBtn(selectedSub: $selectedSub, icon: "signpost.right.and.left.circle.fill", iconColor: .orange, label: "All") {
                selectedSub = .reddit(.subFeed(Subreddit(id: "all")))
              }
              
              ListBigBtn(selectedSub: $selectedSub, icon: "bookmark.circle.fill", iconColor: .green, label: "Saved") {
                selectedSub = .reddit(.subFeed(Subreddit(id: "saved")))
              }
            }
          }
          .frame(maxWidth: .infinity)
          .id("bigButtons")
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          
          Section{
            UpsellCard(upsellName: "themesUpsell_01", {
                Text("Tired of Winstons current look? Try the theme editor in settings now!")
                .winstonShiny()
              .fontWeight(.semibold)
              .font(.system(size: 15))
            })
            .padding()

          }
          .listRowSeparator(.hidden)
//            .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          
          PostsInBoxView(initialSelected: $selectedSub)
            .scrollIndicators(.hidden)
//            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
          
          if multis.count > 0 {
            Section("Multis") {
              ScrollView(.horizontal) {
                HStack(spacing: 16) {
                  ForEach(multis) { multi in
                    MultiLink(initialSelected: $selectedSub, multi: Multi(data: MultiData(entity: multi)))
                  }
                }
                .padding(.horizontal, 16)
              }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
        }
        
        Group {
          if searchText != "" {
            Section("Found subs") {
              let foundSubs = Array(Array(subreddits.filter { ($0.display_name ?? "").lowercased().contains(searchText.lowercased()) }).enumerated())
              ForEach(foundSubs, id: \.self.element.uuid) { i, cachedSub in
                SubItem(selectedSub: $selectedSub, sub: Subreddit(data: SubredditData(entity: cachedSub)), cachedSub: cachedSub)
              }
            }
          } else {
            let favs = subreddits.filter { $0.user_has_favorited && $0.user_is_subscriber }
            if favs.count > 0 {
              Section("Favorites") {
                let favs = Array(favs.sorted(by: { x, y in (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a") }).enumerated())
                ForEach(favs, id: \.self.element) { i, cachedSub in
                  SubItem(selectedSub: $selectedSub, sub: Subreddit(data: SubredditData(entity: cachedSub)), cachedSub: cachedSub)
//                    .equatable()
                    .id("\(cachedSub.uuid ?? "")-fav")
                    .onAppear{
//                      print("Adding" + cachedSub.display_name)
                      UIApplication.shared.shortcutItems?.append(UIApplicationShortcutItem(type: "subFav", localizedTitle: cachedSub.display_name ?? "Test", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .love), userInfo: ["name" : "sub" as NSSecureCoding]))
                    }
                }
                .onDelete(perform: deleteFromFavorites)
                
              }
            }
            
            if disableAlphabetLettersSectionsInSubsList {
              
              Section("Subs") {
                let subs = Array(subreddits.filter({ $0.user_is_subscriber }).sorted(by: { x, y in (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a") }).enumerated())
                ForEach(subs, id: \.self.element) { i, cachedSub in
                  SubItem(selectedSub: $selectedSub, sub: Subreddit(data: SubredditData(entity: cachedSub)), cachedSub: cachedSub)
//                    .equatable()
                }
              }
              
            } else {
              
              ForEach(sections.keys.sorted(), id: \.self) { letter in
                Section(header: Text(letter)) {
                  if let arr = sections[letter] {
                    let subs = Array(arr.sorted(by: { x, y in
                      (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a")
                    }).enumerated())
                    ForEach(subs, id: \.self.element.uuid) { i, cachedSub in
                      SubItem(selectedSub: $selectedSub, sub: Subreddit(data: SubredditData(entity: cachedSub)), cachedSub: cachedSub)
//                        .equatable()
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
        .themedListSection()
      }
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
      .log(subreddits.count, subreddits.map { ($0.name, $0.display_name) })
    }
  }
  
  func deleteFromFavorites(at offsets: IndexSet) {
    for i in offsets {
      Task(priority: .background) {
        Subreddit(data: SubredditData(entity: subreddits.filter { $0.user_has_favorited && $0.user_is_subscriber }.sorted(by: { x, y in (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a") })[i])).subscribeToggle(optimistic: true)
      }
    }
  }
  
  func deleteFromList(at offsets: IndexSet, letter: String) {
    for i in offsets {
      if let sub = sections[letter]?.sorted(by: { x, y in
        (x.display_name?.lowercased() ?? "a") < (y.display_name?.lowercased() ?? "a")
      })[i] {
        Task(priority: .background) {
          Subreddit(data: SubredditData(entity: sub)).subscribeToggle(optimistic: true)
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
