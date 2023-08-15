//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI

@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared
  @State var redditAPI = RedditAPI()
  
    var body: some Scene {
        WindowGroup {
            Tabber()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(redditAPI)
        }
    }
}
