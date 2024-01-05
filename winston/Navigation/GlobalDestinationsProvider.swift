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
  
  @Environment(\.tabBarHeight) private var tabBarHeight

  @ViewBuilder var content: () -> C
  var body: some View {
    content()
      .replyModalPresenter()
      .sheet(item: $nav.presentingSheet) { data in
        GeometryReader { geo in
          Group {
            switch data {
            case .editingTheme(let theme): ThemeEditPanel(theme: theme)
            case .announcement(let announcement): AnnouncementSheet(announcement: announcement)
            case .editingCredential(let cred): CredentialEditStack(credential: cred).id("editing-credential-view-\(cred.id)")
            case .tipJar: TipJar()
            case .onboarding: Onboarding().interactiveDismissDisabled(true)
            case .sharedTheme(let themeData): ThemeStoreDetailsView(themeData: themeData)
            }
          }
          .environment(\.tabBarHeight, tabBarHeight)
          .environment(\.sheetHeight, geo.size.height)
        }
        .coordinateSpace(name: "sheet")
        .environment(\.brighterBG, true)
      }
  }
}
