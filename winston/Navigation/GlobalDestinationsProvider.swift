//
//  injectGlobalDestinations.swift
//  winston
//
//  Created by Igor Marcossi on 09/12/23.
//

import SwiftUI
import Defaults

struct GlobalDestinationsProvider<C: View>: View {
  @ObservedObject private var nav = Nav.shared

  @ViewBuilder var content: () -> C
  var body: some View {
    content()
      .replyModalPresenter()
      .sheet(item: $nav.presentingSheet) { data in
        Group {
          switch data {
          case .editingTheme(let theme):
            ThemeEditPanel(theme: theme)
          case .announcement(let announcement):
            AnnouncementSheet(announcement: announcement)
          case .editingCredential(let cred):
            CredentialEditView(credential: cred).id("editing-credential-view-\(cred.id)")
          case .tipJar:
            TipJar()
          case .onboarding:
            Onboarding().interactiveDismissDisabled(true)
          case .sharedTheme(let themeData):
            ThemeStoreDetailsView(themeData: themeData)
          }
        }
        .environment(\.brighterBG, true)
      }
  }
}
