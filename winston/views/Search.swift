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

struct SearchOpton: View {
  @Binding var activeSearchType: SearchType
  var searchType: SearchType
  var body: some View {
    let active = activeSearchType == searchType
    Button {
      withAnimation {
        activeSearchType = searchType
      }
    } label: {
      Text(searchType.rawValue)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RR(12, active ? .blue : .secondary.opacity(0.1)))
        .foregroundColor(active ? .white : .primary)
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke((active ? Color.white : .primary).opacity(0.01), lineWidth: 1))
    }
  }
}
      
struct Search: View {
  @State var searchType: SearchType = .subreddit
  @State var query = ""
  @EnvironmentObject var redditAPI: RedditAPI
    var body: some View {
      GoodNavigator {
        List {
          HStack {
            SearchOpton(activeSearchType: $searchType, searchType: .subreddit)
            SearchOpton(activeSearchType: $searchType, searchType: .user)
            SearchOpton(activeSearchType: $searchType, searchType: .post)
          }
        }
        .listStyle(.plain)
        .navigationTitle("Search")
        .searchable(text: $query, placement: .toolbar)
        .onSubmit(of: .search) {
          switch searchType {
          case .subreddit:
            Task {
              await redditAPI.searchSubreddits(query)
            }
          case .user:
            Task {
              await redditAPI.searchSubreddits(query)
            }
          case .post:
            Task {
              await redditAPI.searchSubreddits(query)
            }
          }
            }
      }
    }
}

//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search()
//    }
//}
