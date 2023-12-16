//
//  eraseAllEntriesOfEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/11/23.
//

import Foundation
import CoreData

func cleanCredentialOrphanEntities() {
  func clean(_ e: String) {
    let context = PersistenceController.shared.primaryBGContext
    let predicates = RedditCredentialsManager.shared.credentials.map { NSPredicate(format: "winstonCredentialID != %@", $0.id as CVarArg)  }
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: e)
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      _ = try context.performAndWait { try context.execute(deleteRequest) }
    } catch _ as NSError { }
  }
  clean("CachedSub")
  clean("CachedMulti")
}
