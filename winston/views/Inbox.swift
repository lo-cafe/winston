//
//  Inbox.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Inbox: View {
  @State var messages: [Message] = []
  @EnvironmentObject var redditAPI: RedditAPI
  
  func fetch(_ loadMore: Bool = false, _ full: Bool = true) async {
    if let newItems = await redditAPI.fetchInbox() {
      await MainActor.run {
        messages = newItems.map { Message(data: $0, api: redditAPI) }
      }
    }
  }
  
  var body: some View {
    GoodNavigator {
      List(messages, id: \.self.id) { message in
        MessageView(message: message, refresh: fetch)
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
      }
      
      .navigationTitle("Inbox")
      .onAppear {
        Task {
          await fetch()
        }
      }
      .refreshable {
        await fetch()
      }
    }
  }
}



//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        Inbox()
//    }
//}
