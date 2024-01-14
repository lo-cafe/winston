//
//  themeFetchingListener.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

struct ThemeFetchingListenerModifier: ViewModifier {
  @ObservedObject private var redditCredentialsManager = RedditCredentialsManager.shared
  @EnvironmentObject var themeStoreAPI: ThemeStoreAPI
  func body(content: Content) -> some View {
    content
      .onOpenURL { url in
        if url.absoluteString.contains("winstonapp://theme/") {
          let themeID = url.lastPathComponent
          Task(priority: .background) {
            if let sharedTheme = await themeStoreAPI.fetchThemeByID(id: themeID) {
              Nav.present(.sharedTheme(sharedTheme))
            }
          }
        }
      }
  }
}

extension View {
  func themeFetchingListener() -> some View {
    self.modifier(ThemeFetchingListenerModifier())
  }
}
