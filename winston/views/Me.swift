//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  @State var router: Router
  @ObservedObject var redditAPI = RedditAPI.shared
  
  init(router: Router) {
    self._router = .init(initialValue: router)
  }
  
  @State private var loading = true
  var body: some View {
    NavigationStack(path: $router.fullPath) {
      Group {
        if let user = redditAPI.me {
          UserView(user: user)
            .id("me-user-view-\(user.id)")
          
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: .screenH - 200 )
            .onAppear {
              Task(priority: .background) {
                await RedditAPI.shared.fetchMe(force: true)
              }
            }
        }
      }
      .injectInTabDestinations(viewControllerHolder: router.navController)
    }
//    .swipeAnywhere()
  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
