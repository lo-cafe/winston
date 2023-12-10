//
//  Inbox.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults

struct Inbox: View {
  @ObservedObject var router: Router
  
  @StateObject private var messages = ObservableArray<Message>()
  @State private var loading = false
  @Default(.redditCredentialSelectedID) private var redditCredentialSelectedID
  @Environment(\.useTheme) private var selectedTheme
  
  func fetch(_ loadMore: Bool = false, _ force: Bool = false) async {
    if messages.data.count > 0 && !force { return }
    await MainActor.run {
      withAnimation {
        loading = true
      }
    }
    if let newItems = await RedditAPI.shared.fetchInbox() {
      await MainActor.run {
        withAnimation {
          loading = false
          messages.data = newItems.map { Message(data: $0) }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.fullPath) {
      Group {
        List {
          ForEach(messages.data, id: \.self.id) { message in
            MessageLink(message: message)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        }
        .themedListBG(selectedTheme.lists.bg)
        .scrollContentBackground(.hidden)
      }
      .injectInTabDestinations()
      .loader(loading)
      .onAppear {
        Task(priority: .background) {
          await fetch()
        }
      }
      .refreshable {
        await fetch(false, true)
      }
      .onChange(of: redditCredentialSelectedID) { _ in
        messages.data = []
        Task(priority: .background) { await fetch(false, true) }
      }
      .navigationTitle("Inbox")
    }
    .swipeAnywhere()
  }
}



//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        Inbox()
//    }
//}
