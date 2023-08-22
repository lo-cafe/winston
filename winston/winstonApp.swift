//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI
import AlertToast
import Defaults

@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared
  @State var redditAPI = RedditAPI()
  @Default(.preferredThemeMode) var preferredThemeMode
    var body: some Scene {
        WindowGroup {
            Tabber()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(redditAPI)
                .alertToastRoot()
                .preferredColorScheme(preferredThemeMode.id == 0 ? nil : preferredThemeMode.id == 1 ? .light : .dark)
        }
    }
}
