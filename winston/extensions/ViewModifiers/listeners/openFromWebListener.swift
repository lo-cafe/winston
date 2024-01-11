//
//  openFromWebListener.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

extension View {
  func openFromWebListener() -> some View {
    self
      .onOpenURL { url in
        let parsed = parseRedditURL(url.absoluteString)
        withAnimation {
          switch parsed {
          case .post(let postID, let subID):
            Nav.fullTo(.posts, .reddit(.post(Post(id: postID, subID: subID))))
          case .subreddit(let name):
            Nav.fullTo(.posts, .reddit(.subFeed(Subreddit(id: name))))
          case .user(let username):
            Nav.fullTo(.posts, .reddit(.user(User(id: username))))
          default:
            let urlStringWithoutScheme = url.absoluteString.replacingOccurrences(of: "winstonapp://", with: "")
            
            if let safariURL = URL(string: "https://" + urlStringWithoutScheme) {
              if isImageUrl(safariURL.absoluteString) {
                let imageView = ImageView(url: safariURL)
                let hostingController = UIHostingController(rootView: imageView)
                hostingController.overrideUserInterfaceStyle = .dark
                UIApplication.shared.firstKeyWindow?.rootViewController?.present(hostingController, animated: true)
              } else {
                Nav.openURL(safariURL)
              }
            }
          }
        }
      }
  }
}
