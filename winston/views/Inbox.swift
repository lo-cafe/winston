//
//  Inbox.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults

struct Inbox: View {
  @State var router: Router
  
  @State private var messages: [Message] = []
  @State private var loading = false
  @Default(.GeneralDefSettings) private var generalDefSettings
  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
  @Environment(\.useTheme) private var selectedTheme
  
  init(router: Router) {
    self._router = .init(initialValue: router)
  }
  
  func fetcher(_ after: String?, _ sorting: SubListingSortOption?, _ searchQuery: String?, _ flair: String?) async -> ([RedditEntityType]?, String?)? {
    if let result = await RedditAPI.shared.fetchInbox(after: after ?? "", limit: subredditFeedDefSettings.chunkLoadSize), let entities = result.0 {
      return (entities.map { RedditEntityType.message(Message(data: $0)) }, result.1)
    }
    return nil
  }
  
  var body: some View {
    NavigationStack(path: $router.fullPath) {
      RedditListingFeed(feedId: "inbox", title: "Inbox", theme: selectedTheme.lists.bg, fetch: fetcher, disableSearch: true)
        .injectInTabDestinations()
        .attachViewControllerToRouter(tabID: .inbox)
    }
  }
}



//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        Inbox()
//    }
//}
