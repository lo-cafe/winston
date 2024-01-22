//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI
import CoreData
import WhatsNewKit
import Nuke

var shortcutItemToProcess: UIApplicationShortcutItem?
@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      AppContent()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(\.primaryBGContext, persistenceController.primaryBGContext)
        .environment(
          \.whatsNew,
           WhatsNewEnvironment(currentVersion: .current(), whatsNewCollection: getCurrentChangelog())
        )
        .task {
          ImagePipeline.shared = ImagePipeline(configuration: .withDataCache(name: "lo.cafe.winston.datacache", sizeLimit: 1024 * 1024 * 300))
        }
    }
  }
  
  func addQuickActions() {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var subreddits: FetchedResults<CachedSub>
    
    var searchUserInfo: [String: NSSecureCoding] {
      return ["name" : "search" as NSSecureCoding]
    }
    var savedInfo: [String: NSSecureCoding] {
      return ["name" : "saved" as NSSecureCoding]
    }
    var statususerInfo: [String: NSSecureCoding] {
      return ["name" : "status" as NSSecureCoding]
    }
    var contactuserInfo: [String: NSSecureCoding] {
      return ["name" : "contact" as NSSecureCoding]
    }
    
    UIApplication.shared.shortcutItems = [
      UIApplicationShortcutItem(type: "Search", localizedTitle: "Search", localizedSubtitle: "Search a Subreddit", icon: UIApplicationShortcutIcon(type: .search), userInfo: searchUserInfo),
      UIApplicationShortcutItem(type: "Saved", localizedTitle: "Saved", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .bookmark), userInfo: savedInfo),
    ]
    
  }
}

