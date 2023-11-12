//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  var reset: Bool
  @StateObject var router: Router
  @ObservedObject var redditAPI = RedditAPI.shared
  
  @State private var loading = true
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector(routerProxy: RouterProxy(router)) { _ in
        Group {
          if let user = redditAPI.me {
            UserView(user: user)
            
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
        .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
      }
//      .defaultNavDestinations(router)
    }
    .swipeAnywhere(routerProxy: RouterProxy(router), routerContainer: router.isRootWrapper)
  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
