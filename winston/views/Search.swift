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
  @State private var query = ""
  @EnvironmentObject private var redditAPI: RedditAPI
  @StateObject private var router = Router()
  
  func fetch() {
    if query == "" { return }
    withAnimation {
      loading = true
    }
    switch searchType {
    case .subreddit:
      resultsSubs.data.removeAll()
      Task {
        if let subs = await redditAPI.searchSubreddits(query)?.map({ Subreddit(data: $0, api: redditAPI) }) {
          await MainActor.run {
            withAnimation {
              resultsSubs.data = subs
              loading = false
            }
          }
        }
      }
    case .user:
      resultsUsers.data.removeAll()
      Task {
        if let users = await redditAPI.searchUsers(query)?.map({ User(data: $0, api: redditAPI) }) {
          await MainActor.run {
            withAnimation {
              resultsUsers.data = users
              loading = false
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
      .loader(loading)
      .navigationTitle("Search")
      .searchable(text: $query, placement: .toolbar)
      .onChange(of: searchType) { _ in fetch() }
      .onChange(of: reset) { _ in router.path = NavigationPath() }
      .onChange(of: query) { val in
        if val == "" {
          resultsSubs.data = []
          resultsUsers.data = []
        }
      }
      .refreshable { fetch() }
      .onSubmit(of: .search) { fetch() }
      .navigationDestination(for: PostViewPayload.self) { postPayload in
        PostView(post: postPayload.post, subreddit: postPayload.sub, highlightID: postPayload.highlightID)
          .environmentObject(router)
      }
      .navigationDestination(for: PostViewContainerPayload.self) { postPayload in
        PostViewContainer(post: postPayload.post, sub: postPayload.sub, highlightID: postPayload.highlightID)
          .environmentObject(router)
      }
      .navigationDestination(for: SubViewType.self) { sub in
        switch sub {
        case .posts(let sub):
          SubredditPosts(subreddit: sub)
            .environmentObject(router)
        case .info(let sub):
          SubredditInfo(subreddit: sub)
            .environmentObject(router)
        }
      }
      .navigationDestination(for: SubredditPostsContainerPayload.self) { payload in
        SubredditPostsContainer(sub: payload.sub, highlightID: payload.highlightID)
          .environmentObject(router)
      }
      .navigationDestination(for: User.self) { user in
        UserView(user: user)
          .environmentObject(router)
      }
      .environmentObject(router)
    }
  }
}

//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search()
//    }
//}
