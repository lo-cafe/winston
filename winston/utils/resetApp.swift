//
//  resetApp.swift
//  winston
//
//  Created by Igor Marcossi on 04/09/23.
//

import Foundation
import Defaults
import KeychainAccess
import CoreData

func resetApp() {
  resetCaches()
  resetCoreData()
  resetPreferences()
  resetCredentials()
}

func resetCredentials() {
  RedditCredentialsManager.shared.credentials.forEach { $0.delete() }
  
  let credentialsKeychain = Keychain(service: "lo.cafe.winston.reddit-credentials").synchronizable(Defaults[.BehaviorDefSettings].iCloudSyncCredentials)
  
  credentialsKeychain["apiAppID"] = nil
  credentialsKeychain["apiAppSecret"] = nil
  credentialsKeychain["accessToken"] = nil
  credentialsKeychain["refreshToken"] = nil
}

func resetPreferences() {
  UserDefaults.standard.removeAll()
}

func resetCaches() {
  Caches.postsAttrStr.cache.removeAll()
  Caches.videos.cache.removeAll()
}

func resetCoreData() {
  let container = PersistenceController.shared.container
  let entities = container.managedObjectModel.entities
  for entity in entities {
        delete(entityName: entity.name!)
  }
  
  func delete(entityName: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      _ = try container.viewContext.performAndWait {
        try container.viewContext.executeAndMergeChanges(deleteRequest)
//        try container.viewContext.save()
      }
    } catch let error as NSError {
      debugPrint(error)
    }
  }
}
