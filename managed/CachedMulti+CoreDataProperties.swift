//
//  CachedMulti+CoreDataProperties.swift
//  winston
//
//  Created by Igor Marcossi on 25/08/23.
//
//

import Foundation
import CoreData


extension CachedMulti {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedMulti> {
    return NSFetchRequest<CachedMulti>(entityName: "CachedMulti")
  }
  
  @NSManaged public var display_name: String?
  @NSManaged public var icon_url: String?
  @NSManaged public var key_color: String?
  @NSManaged public var name: String?
  @NSManaged public var over_18: Bool
  @NSManaged public var path: String?
  @NSManaged public var uuid: String?
  @NSManaged public var subreddits: Set<CachedSub>?
  @NSManaged public var winstonCredentialID: UUID?
  
  convenience init(data: MultiData, context: NSManagedObjectContext, credentialID: UUID) {
    self.init(context: context)
    update(data, credentialID: credentialID)
  }
  
  public var subsArray: [CachedSub] {
    let set = subreddits ?? []
    return set.sorted {
      $0.display_name ?? "" < $1.display_name ?? ""
    }
  }
  
  func getSubEntities(_ subs: [MultiSub], context: NSManagedObjectContext, credentialID: UUID) -> [CachedSub] {
    guard let currentCredentialID = RedditCredentialsManager.shared.selectedCredential?.id else { return [] }
    var cachedSubs: [String:CachedSub] = [:]
    let fetchRequest = NSFetchRequest<CachedSub>(entityName: "CachedSub")
      fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
    if let results = (context.performAndWait { try? context.fetch(fetchRequest) }) {
      results.forEach { cachedSub in
        context.performAndWait {
          if let name = cachedSub.name {
            cachedSubs[name] = cachedSub
          }
        }
      }
    }
    
    return subs.compactMap { subData in
      if let data = subData.data, let found = cachedSubs[data.name] { return found }
      if let y = subData.data {
        let newCachedSub = CachedSub(data: y, context: context, credentialID: currentCredentialID)
        return newCachedSub
      }
      return nil
    }
  }
  
  func update(_ data: MultiData, credentialID: UUID) {
    guard let ctx = self.managedObjectContext else { return }
    let subs = getSubEntities(data.subreddits ?? [], context: ctx, credentialID: credentialID)
    self.display_name = data.display_name
    self.icon_url = data.icon_url ?? ""
    self.key_color = data.key_color ?? ""
    self.name = data.name
    self.over_18 = data.over_18 ?? false
    self.path = data.path
    self.uuid = data.id
    self.subreddits = Set(subs)
    self.winstonCredentialID = credentialID
  }
  
}

// MARK: Generated accessors for subreddits
extension CachedMulti {
  
  @objc(addSubredditsObject:)
  @NSManaged public func addToSubreddits(_ value: CachedSub)
  
  @objc(removeSubredditsObject:)
  @NSManaged public func removeFromSubreddits(_ value: CachedSub)
  
  @objc(addSubreddits:)
  @NSManaged public func addToSubreddits(_ values: NSSet)
  
  @objc(removeSubreddits:)
  @NSManaged public func removeFromSubreddits(_ values: NSSet)
  
}

extension CachedMulti : Identifiable {
  
}
