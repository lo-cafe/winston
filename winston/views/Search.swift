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
  case post = "Post"
}

struct SearchOption: View {
  var activateSearchType: ()->()
  var active: Bool
  var searchType: SearchType
  var body: some View {
    Text(searchType.rawValue)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Capsule(style: .continuous).fill(active ? Color.accentColor : .secondary.opacity(0.15)))
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

enum SearchTypeArr {
  case subreddit([Subreddit])
  case user([User])
  case post([Post])
}

struct Search: View {
  var reset: Bool
  @StateObject var router: Router
  @State private var searchType: SearchType = .subreddit
  @StateObject private var resultsSubs = ObservableArray<Subreddit>()
  @StateObject private var resultsUsers = ObservableArray<User>()
  @StateObject private var resultPosts = ObservableArray<Post>()
  @State private var loading = false
  @State private var hideSpinner = false
  @StateObject var searchQuery = DebouncedText(delay: 0.25)
  
  @State private var dummyAllSub: Subreddit? = nil
  @State private var searchViewLoaded: Bool = false
  
  @Environment(\.useTheme) private var theme
  @EnvironmentObject private var routerProxy: RouterProxy
  
  func fetch() {
    if searchQuery.text == "" { return }
    withAnimation {
      loading = true
    }
    switch searchType {
    case .subreddit:
      resultsSubs.data.removeAll()
      Task(priority: .background) {
        if let subs = await RedditAPI.shared.searchSubreddits(searchQuery.text)?.map({ Subreddit(data: $0, api: RedditAPI.shared) }) {
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
        if let users = await RedditAPI.shared.searchUsers(searchQuery.text)?.map({ User(data: $0, api: RedditAPI.shared) }) {
          await MainActor.run {
            withAnimation {
              resultsUsers.data = users
              loading = false
              
              hideSpinner = resultsUsers.data.isEmpty
            }
          }
        }
      }
    case .post:
      resultPosts.data.removeAll()
      Task(priority: .background) {
        if let dummyAllSub = dummyAllSub, let result = await dummyAllSub.fetchPosts(searchText: searchQuery.text), let newPosts = result.0 {
          await MainActor.run {
            withAnimation {
              resultPosts.data = newPosts
              loading = false
              
              hideSpinner = resultPosts.data.isEmpty
            }
          }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector(routerProxy: RouterProxy(router)) {
        List {
          Group {
            Section {
              HStack {
                SearchOption(activateSearchType: { searchType = .subreddit }, active: searchType == SearchType.subreddit, searchType: .subreddit)
                SearchOption(activateSearchType: { searchType = .user }, active: searchType == SearchType.user, searchType: .user)
                SearchOption(activateSearchType: { searchType = .post }, active: searchType == SearchType.post, searchType: .post)
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
              case .post:
                if let dummyAllSub = dummyAllSub {
                  ForEach(resultPosts.data) { post in
                    PostLink(post: post, sub: dummyAllSub, routerProxy: routerProxy)
                      .equatable()
                      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                      .animation(.default, value: resultPosts.data)
                  }
                }
              }
            }
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .themedListBG(theme.lists.bg)
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        .loader(loading, hideSpinner && !searchQuery.text.isEmpty)
        .onChange(of: searchType) { _ in fetch() }
        .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
        .onChange(of: searchQuery.debounced) { val in
          if val == "" {
            resultsSubs.data = []
            resultsUsers.data = []
            resultPosts.data = []
          }
          fetch()
        }
      }
      .searchable(text: $searchQuery.text, placement: .toolbar)
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.none)
      .refreshable { fetch() }
      .onSubmit(of: .search) { fetch() }
      .navigationTitle("Search")
      .onAppear() {
        if !searchViewLoaded {
          dummyAllSub = Subreddit(id: "all", api: RedditAPI.shared)
          searchViewLoaded = true
        }
      }
//      .defaultNavDestinations(router)
    }
    .swipeAnywhere(routerProxy: RouterProxy(router), routerContainer: router.isRootWrapper)
  }
}

//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search()
//    }
//}
