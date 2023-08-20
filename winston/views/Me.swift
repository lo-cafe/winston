//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  var reset: Bool
  @ObservedObject var router: Router
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
  @State private var loading = true
  var body: some View {
    NavigationStack(path: $router.path) {
      Group {
        if let user = redditAPI.me {
          UserView(user: user)
            .defaultNavDestinations(router)
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
            .onAppear {
              Task(priority: .background) {
                await redditAPI.fetchMe(force: true)
              }
            }
        }
      }
    }
    .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
    .swipeAnywhere(router: router)
  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
