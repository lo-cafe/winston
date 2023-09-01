//
//  LocalFavorite+CoreDataProperties.swift
//  winston
//
//  Created by Daniel Inama on 01/09/23.
//

import Foundation

extension LocalFavorite {
  @nonobjc public class override func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
    return NSFetchRequest<LocalFavorite>(entityName: "LocalFavorite")
  }
  
  @NSManaged public var title: String?
  @NSManaged public var subreddits: Set<CachedSub>
  
  public var subsArray: [CachedSub]{
    let set = subreddits ?? []
    return set.sorted{
      $0.display_name ?? "" < $1.display_name ?? ""
    }
  }
}

// MARK: Generated accessors for subreddits
extension LocalFavorite {
  @objc(addSubredditsObject:)
  @NSManaged public func addToSubreddits(_ value: CachedSub)

  @objc(removeSubredditsObject:)
  @NSManaged public func removeFromSubreddits(_ value: CachedSub)

  @objc(addSubreddits:)
  @NSManaged public func addToSubreddits(_ values: NSSet)

  @objc(removeSubreddits:)
  @NSManaged public func removeFromSubreddits(_ values: NSSet)
  
}

extension LocalFavorite: Identifiable {
  
}
