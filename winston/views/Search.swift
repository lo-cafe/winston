//
//  Search.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

enum SearchType: String {
  case subreddit = "Subreddit"
  case user = "User"
}

struct SearchOption: View {
  var activateSearchType: ()->()
  var active: Bool
  var searchType: SearchType
  var body: some View {
    Text(searchType.rawValue)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Capsule(style: .continuous).fill(active ? .blue : .secondary.opacity(0.1)))
      .foregroundColor(active ? .white : .primary)
      .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke((active ? Color.white : .primary).opacity(0.01), lineWidth: 1))
      .contentShape(Capsule())
      .onTapGesture {
        withAnimation(.interactiveSpring()) {
          activateSearchType()
        }
      }
      .shrinkOnTap()
  }
}

typealias SearchTypeArr = Either<[Subreddit], [User]>

struct Search: View {
  var reset: Bool
  @State private var searchType: SearchType = .subreddit
  @StateObject private var resultsSubs = ObservableArray<Subreddit>()
  @StateObject private var resultsUsers = ObservableArray<User>()
  @State private var loading = false
  @State private var hideSpinner = false
  @StateObject var searchQuery = DebouncedText(delay: 0.25)
  @EnvironmentObject private var redditAPI: RedditAPI
  @StateObject private var router = Router()
  
  func fetch() {
    if searchQuery.text == "" { return }
    withAnimation {
      loading = true
    }
    switch searchType {
    case .subreddit:
      resultsSubs.data.removeAll()
      Task(priority: .background) {
        if let subs = await redditAPI.searchSubreddits(searchQuery.text)?.map({ Subreddit(data: $0, api: redditAPI) }) {
          await MainActor.run {
            withAnimation {
              resultsSubs.data = subs
              loading = false
              
              hideSpinner = resultsSubs.data.isEmpty
            }
          }
        }
      }
    case .user:
      resultsUsers.data.removeAll()
      Task(priority: .background) {
        if let users = await redditAPI.searchUsers(searchQuery.text)?.map({ User(data: $0, api: redditAPI) }) {
          await MainActor.run {
            withAnimation {
              resultsUsers.data = users
              loading = false
              
              hideSpinner = resultsUsers.data.isEmpty
            }
          }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        Group {
          Section {
            HStack {
              SearchOption(activateSearchType: { searchType = .subreddit }, active: searchType == SearchType.subreddit, searchType: .subreddit)
              SearchOption(activateSearchType: { searchType = .user }, active: searchType == SearchType.user, searchType: .user)
            }
            .id("options")
          }
          
          Section {
            switch searchType {
            case .subreddit:
              ForEach(resultsSubs.data) { sub in
                SubredditLink(sub: sub)
              }
            case .user:
              ForEach(resultsUsers.data) { user in
                UserLink(user: user)
              }
            }
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
      }
      .introspect(.list, on: .iOS(.v15)) { list in
        list.backgroundColor = UIColor.systemGroupedBackground
      }
      .introspect(.list, on: .iOS(.v16, .v17)) { list in
        list.backgroundColor = UIColor.systemGroupedBackground
      }
      .listStyle(.plain)
      .loader(loading, hideSpinner && !searchQuery.text.isEmpty)
      .searchable(text: $searchQuery.text, placement: .toolbar)
      .onChange(of: searchType) { _ in fetch() }
      .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
      .onChange(of: searchQuery.debounced) { val in
        if val == "" {
          resultsSubs.data = []
          resultsUsers.data = []
        }
        fetch()
      }
      .refreshable { fetch() }
      .onSubmit(of: .search) { fetch() }
      .navigationTitle("Search")
      .defaultNavDestinations(router)
    }
  }
}

//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search()
//    }
//}
