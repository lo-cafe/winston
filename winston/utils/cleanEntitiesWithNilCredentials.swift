//
//  eraseAllEntriesOfEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/11/23.
//

import Foundation
import CoreData

func cleanEntitiesWithNilCredentials() {
  func clean(_ e: String) {
    let container = PersistenceController.shared.container
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: e)
    fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == nil")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try container.viewContext.execute(deleteRequest)
    } catch let error as NSError { }
  }
  clean("CachedSub")
  clean("CachedMulti")
  Task(priority: .background) { await RedditAPI.shared.fetchSubs() }
  Task(priority: .background) { await RedditAPI.shared.fetchMyMultis() }
}
