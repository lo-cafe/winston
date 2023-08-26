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
  
    public var subsArray: [CachedSub] {
      let set = subreddits ?? []
        return set.sorted {
          $0.display_name ?? "" < $1.display_name ?? ""
        }
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
