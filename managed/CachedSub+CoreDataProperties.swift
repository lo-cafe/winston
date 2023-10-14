//
//  CachedSub+CoreDataProperties.swift
//  winston
//
//  Created by Igor Marcossi on 25/08/23.
//
//

import Foundation
import CoreData


extension CachedSub {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedSub> {
        return NSFetchRequest<CachedSub>(entityName: "CachedSub")
    }

    @NSManaged public var allow_galleries: Bool
    @NSManaged public var allow_images: Bool
    @NSManaged public var allow_videos: Bool
    @NSManaged public var banner_background_color: String?
    @NSManaged public var banner_background_image: String?
    @NSManaged public var banner_img: String?
    @NSManaged public var community_icon: String?
    @NSManaged public var display_name: String?
    @NSManaged public var header_img: String?
    @NSManaged public var icon_img: String?
    @NSManaged public var key_color: String?
    @NSManaged public var name: String?
    @NSManaged public var over18: Bool
    @NSManaged public var primary_color: String?
    @NSManaged public var restrict_commenting: Bool
    @NSManaged public var subscribers: Double
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var user_flair_background_color: String?
    @NSManaged public var user_has_favorited: Bool
    @NSManaged public var user_is_banned: Bool
    @NSManaged public var user_is_moderator: Bool
    @NSManaged public var user_is_subscriber: Bool
    @NSManaged public var uuid: String?
  
  convenience init(data: SubredditData, context: NSManagedObjectContext) {
    self.init(context: context)
    update(data: data)
  }
  
  func update(data x: SubredditData) {
    self.uuid = x.name
    self.allow_galleries = x.allow_galleries ?? false
    self.allow_images = x.allow_images ?? false
    self.allow_videos = x.allow_videos ?? false
    self.over18 = x.over18 ?? false
    self.restrict_commenting = x.restrict_commenting ?? false
    self.user_has_favorited = x.user_has_favorited ?? false
    self.user_is_banned = x.user_is_banned ?? false
    self.user_is_moderator = x.user_is_moderator ?? false
    self.user_is_subscriber = x.user_is_subscriber ?? false
    self.banner_background_color = x.banner_background_color
    self.banner_background_image = x.banner_background_image
    self.banner_img = x.banner_img
    self.community_icon = x.community_icon
    self.display_name = x.display_name
    self.header_img = x.header_img
    self.icon_img = x.icon_img
    self.key_color = x.key_color
    self.name = x.name
    self.primary_color = x.primary_color
    self.title = x.title
    self.url = x.url
    self.user_flair_background_color = x.user_flair_background_color
    self.subscribers = Double(x.subscribers ?? 0)
  }

}

extension CachedSub : Identifiable {

}
