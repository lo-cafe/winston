//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  @ObservedObject var router: Router
  @ObservedObject var redditAPI = RedditAPI.shared
  
  @State private var loading = true
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector {
        Group {
          if let user = redditAPI.me {
            UserView(user: user)
              .id("me-user-view-\(user.id)")
            
          } else {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
              .onAppear {
                Task(priority: .background) {
                  await RedditAPI.shared.fetchMe(force: true)
                }
              }
          }
        }
      }
    }
    .swipeAnywhere()
  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
