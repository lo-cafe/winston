//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI

@main
struct winstonApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
