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
  let credentialsKeychain = Keychain(service: "lo.cafe.winston.reddit-credentials")
  
  credentialsKeychain["apiAppID"] = nil
  credentialsKeychain["apiAppSecret"] = nil
  credentialsKeychain["accessToken"] = nil
  credentialsKeychain["refreshToken"] = nil
}

func resetPreferences() {
  UserDefaults.standard.removeAll()
}

func resetCaches() {
  Caches.ytPlayers.cache.removeAll()
  Caches.postsAttrStr.cache.removeAll()
  Caches.postsPreviewModels.cache.removeAll()
  ThingEntityCache.shared.thingEntities.removeAll()
  SharedVideoCache.shared.cache.removeAll()
  AvatarCache.shared.data.removeAll()
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
      try container.viewContext.execute(deleteRequest)
    } catch let error as NSError {
      debugPrint(error)
    }
  }
}
