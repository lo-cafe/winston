//
//  Inbox.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults

struct Inbox: View {
  var reset: Bool
  @StateObject var router: Router
  @StateObject var messages = ObservableArray<Message>()
  @State var loading = false
  @EnvironmentObject var redditAPI: RedditAPI
  @Environment(\.useTheme) private var selectedTheme
  
  func fetch(_ loadMore: Bool = false, _ force: Bool = false) async {
    if messages.data.count > 0 && !force { return }
    await MainActor.run {
      withAnimation {
        loading = true
      }
    }
    if let newItems = await redditAPI.fetchInbox() {
      await MainActor.run {
        withAnimation {
          loading = false
          messages.data = newItems.map { Message(data: $0, api: redditAPI) }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector(routerProxy: RouterProxy(router)) {
        List {
          Group {
            if loading {
              ProgressView()
                .frame(maxWidth: .infinity, minHeight: 500)
                .id("loading")
            } else {
              ForEach(messages.data, id: \.self.id) { message in
                MessageLink(message: message)
              }
            }
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        }
        .themedListBG(selectedTheme.lists.bg)
        .scrollContentBackground(.hidden)
        .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
      }
      .onAppear {
        Task(priority: .background) {
          await fetch()
        }
      }
      .refreshable {
        await fetch(false, true)
      }
      .navigationTitle("Inbox")
    }
    .swipeAnywhere(routerContainer: SwipeAnywhereRouterContainer(router))
  }
}



//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        Inbox()
//    }
//}
