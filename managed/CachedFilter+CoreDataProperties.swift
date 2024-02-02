//
//  CachedFilter+CoreDataProperties.swift
//  winston
//
//  Created by Igor Marcossi on 25/01/24.
//
//

import Foundation
import CoreData


struct ShallowCachedFilter: Equatable, Identifiable, Hashable {
  var id: String { self.text + self.subID }
  private(set) var bgColor: String?
  private(set) var subID: String
  private(set) var text: String
  private(set) var textColor: String?
  fileprivate var rawType: String
  var type: CachedFilter.FilterType {
    get { CachedFilter.FilterType(rawValue: self.rawType) ?? .flair }
  }
}

extension CachedFilter {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedFilter> {
    return NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
  }
  
  @NSManaged public var bgColor: String?
  @NSManaged public var subID: String
  @NSManaged public var text: String
  @NSManaged public var textColor: String?
  @NSManaged fileprivate var rawType: String
  
  convenience init(context: NSManagedObjectContext, subID: String, _ flair: Flair) {
    self.init(context: context)
    self.update(flair, subID: subID)
  }
  
  func getShallow() -> ShallowCachedFilter {
    ShallowCachedFilter(bgColor: bgColor, subID: subID, text: text, textColor: textColor, rawType: rawType)
  }
  
  var type: FilterType {
    get { self.managedObjectContext?.performAndWait {
      FilterType(rawValue: self.rawType) ?? .flair
    } ?? .flair }
    set { self.managedObjectContext?.performAndWait { self.rawType = newValue.rawValue } }
  }
  
  enum FilterType: String {
    case flair, modFlair, custom
  }
  
  func update(_ flair: Flair, subID: String? = nil) {
    self.bgColor = flair.background_color
    self.text = flair.text
    if let subID { self.subID = subID }
    self.type = (flair.mod_only ?? false) ? .modFlair : .flair
    self.textColor = flair.text_color
  }
  
}

extension CachedFilter : Identifiable {
  public var id: String { self.text + self.subID }
}
