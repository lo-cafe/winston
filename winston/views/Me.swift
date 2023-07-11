//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  var reset: Bool
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
  @State var loading = true
  var body: some View {
    GoodNavigator {
      Group {
        if let user = redditAPI.me {
          UserView(user: user)
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
            .onAppear {
              Task {
                await redditAPI.fetchMe()
              }
            }
        }
        
//        if let refreshToken = redditAPI.loggedUser.refreshToken {
//          Text(refreshToken)
//          Button("Logout") {
//            redditAPI.loggedUser.accessToken = nil
//            redditAPI.loggedUser.refreshToken = nil
//            redditAPI.loggedUser.expiration = nil
//            redditAPI.loggedUser.lastRefresh = nil
//          }
//        } else {
//          Button("Open auth") {
//            openURL(redditAPI.getAuthorizationCodeURL())
//          }
//        }
      }
    }

  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
