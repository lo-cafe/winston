//
//  Search.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import NukeUI
import Defaults

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
  @State var router: Router
  
  @State private var searchType: SearchType = .subreddit
  @State private var resultsSubs: [Subreddit] = []
  @State private var resultsUsers: [User] = []
  @State private var resultPosts: [Post] = []
  @State private var loading = false
  @State private var hideSpinner = false
  @State var searchQuery = Debouncer("", delay: 0.25)
  
  @State private var dummyAllSub: Subreddit? = nil
  @State private var searchViewLoaded: Bool = false
  
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  @Environment(\.useTheme) private var theme
  @Environment(\.contentWidth) private var contentWidth
  
  init(router: Router) {
    self._router = .init(initialValue: router)
  }
  
  func fetch() {
    if searchQuery.value == "" { return }
    withAnimation {
      loading = true
    }
    switch searchType {
    case .subreddit:
      resultsSubs.removeAll()
      Task(priority: .background) {
        if let subs = await RedditAPI.shared.searchSubreddits(searchQuery.value)?.map({ Subreddit(data: $0) }) {
          await MainActor.run {
            withAnimation {
              resultsSubs = subs
              loading = false
              
              hideSpinner = resultsSubs.isEmpty
            }
          }
        }
      }
    case .user:
      resultsUsers.removeAll()
      Task(priority: .background) {
        if let users = await RedditAPI.shared.searchUsers(searchQuery.value)?.map({ User(data: $0) }) {
          await MainActor.run {
            withAnimation {
              resultsUsers = users
              loading = false
              
              hideSpinner = resultsUsers.isEmpty
            }
          }
        }
      }
    case .post:
      resultPosts.removeAll()
      Task(priority: .background) {
        if let dummyAllSub = dummyAllSub, let result = await dummyAllSub.fetchPosts(searchText: searchQuery.value), let newPosts = result.0 {
          let actualNewPosts = newPosts.compactMap {
            if case .post(let post) = $0 {
              return post
            }
            return nil
          }
          await MainActor.run {
            withAnimation {
              resultPosts = actualNewPosts
              loading = false
              
              hideSpinner = resultPosts.isEmpty
            }
          }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.fullPath) {
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
              ForEach(resultsSubs) { sub in
                SubredditLink(sub: sub)
              }
            case .user:
              ForEach(resultsUsers) { user in
                UserLink(user: user)
              }
            case .post:
              if let dummyAllSub = dummyAllSub {
                ForEach(resultPosts) { post in
                  if let winstonData = post.winstonData {
                    //                      SwipeRevolution(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post) { controller in
                    PostLink(id: post.id, theme: theme.postLinks, showSub: true, compactPerSubreddit: nil, contentWidth: contentWidth, defSettings: postLinkDefSettings)
//                    .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
                    //                      }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .animation(.default, value: resultPosts)
                    .environment(\.contextPost, post)
                    .environment(\.contextSubreddit, dummyAllSub)
                    .environment(\.contextPostWinstonData, winstonData)
                  }
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
      .loader(loading, hideSpinner && !searchQuery.value.isEmpty)
      .attachViewControllerToRouter(tabID: .search)
      .injectInTabDestinations()
      .scrollDismissesKeyboard(.automatic)
      .searchable(text: $searchQuery.value, placement: .toolbar)
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.none)
      .refreshable { fetch() }
      .onSubmit(of: .search) { fetch() }
      .navigationTitle("Search")
      .onChange(of: searchType) { _ in fetch() }
      .onChange(of: searchQuery.debounced) { val in
        if val == "" {
          resultsSubs = []
          resultsUsers = []
          resultPosts = []
        }
        fetch()
      }
      .onAppear() {
        if !searchViewLoaded {
          dummyAllSub = Subreddit(id: "all")
          searchViewLoaded = true
        }
      }
    }
//    .swipeAnywhere()
  }
}
