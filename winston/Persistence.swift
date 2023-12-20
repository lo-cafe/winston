//
//  Persistence.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  
  //    static var preview: PersistenceController = {
  ////        let result = PersistenceController(inMemory: true)
  ////        let viewContext = result.container.viewContext
  ////        for _ in 0..<10 {
  ////            let newItem = Item(context: viewContext)
  ////            newItem.timestamp = Date()
  ////        }
  ////        do {
  ////            try viewContext.save()
  ////        } catch {
  ////            // Replace this implementation with code to handle the error appropriately.
  ////            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
  ////            let nsError = error as NSError
  ////            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
  ////        }
  ////        return result
  //    }()
  
//  let container: NSPersistentContainer
  let container: NSPersistentCloudKitContainer
  let primaryBGContext: NSManagedObjectContext
  
  init(inMemory: Bool = false) {
//    container = NSPersistentContainer(name: "winston")
    container = NSPersistentCloudKitContainer(name: "winston")
        
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    self.primaryBGContext = container.newBackgroundContext()
    self.primaryBGContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    self.primaryBGContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}

extension NSManagedObjectContext {
    
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(_ batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
