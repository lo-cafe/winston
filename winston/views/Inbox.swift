//
//  Inbox.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Inbox: View {
  var reset: Bool
  @State var messages: [Message] = []
  @State var loading = false
  @EnvironmentObject var redditAPI: RedditAPI
  
  func fetch(_ loadMore: Bool = false, _ force: Bool = false) async {
    if messages.count > 0 && !force { return }
    await MainActor.run {
      withAnimation {
        loading = true
      }
    }
    if let newItems = await redditAPI.fetchInbox() {
      await MainActor.run {
        withAnimation {
          loading = false
          messages = newItems.map { Message(data: $0, api: redditAPI) }
        }
      }
    }
  }
  
  var body: some View {
    GoodNavigator {
      List {
        Group {
          if loading {
            ProgressView()
              .frame(maxWidth: .infinity, minHeight: 500)
          } else {
            ForEach(messages, id: \.self.id) { message in
              MessageView(reset: reset, message: message)
            }
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
      }
      .navigationTitle("Inbox")
      .onAppear {
        Task {
          await fetch()
        }
      }
      .refreshable {
        await fetch(false, true)
      }
    }
  }
}



//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        Inbox()
//    }
//}
