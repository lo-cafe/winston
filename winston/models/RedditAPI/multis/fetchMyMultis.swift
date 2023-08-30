//
//  fetchMyMultis.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Defaults
import Alamofire
import SwiftUI
import CoreData

extension RedditAPI {
  func fetchMyMultis() async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = ["expand_srs":true]
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi/mine",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      ).serializingDecodable([MultiContainerResponse].self).response
      switch response.result {
      case .success(let data):
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        var cachedSubs: [String:CachedSub] = [:]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedSub")
        if let results = (context.performAndWait { try? context.fetch(fetchRequest) as? [CachedSub] }) {
          results.forEach { cachedSub in
            context.performAndWait {
              if let name = cachedSub.name {
                cachedSubs[name] = cachedSub
              }
            }
          }
        }
        
          data.forEach { c in
            let subs: [CachedSub] = c.data?.subreddits?.compactMap { subData in
              if let data = subData.data, let found = cachedSubs[data.name] { return found }
              if let y = subData.data {
//                return context.performAndWait {
                  let newCachedSub = CachedSub(context: context)
                  newCachedSub.allow_galleries = y.allow_galleries ?? false
                  newCachedSub.allow_images = y.allow_images ?? false
                  newCachedSub.allow_videos = y.allow_videos ?? false
                  newCachedSub.over_18 = y.over_18 ?? false
                  newCachedSub.restrict_commenting = y.restrict_commenting ?? false
                  newCachedSub.user_has_favorited = y.user_has_favorited ?? false
                  newCachedSub.user_is_banned = y.user_is_banned ?? false
                  newCachedSub.user_is_moderator = y.user_is_moderator ?? false
                  newCachedSub.user_is_subscriber = y.user_is_subscriber ?? false
                  newCachedSub.banner_background_color = y.banner_background_color
                  newCachedSub.banner_background_image = y.banner_background_image
                  newCachedSub.banner_img = y.banner_img
                  newCachedSub.community_icon = y.community_icon
                  newCachedSub.display_name = y.display_name
                  newCachedSub.header_img = y.header_img
                  newCachedSub.icon_img = y.icon_img
                  newCachedSub.key_color = y.key_color
                  newCachedSub.name = y.name
                  newCachedSub.primary_color = y.primary_color
                  newCachedSub.title = y.title
                  newCachedSub.url = y.url
                  newCachedSub.user_flair_background_color = y.user_flair_background_color
                  newCachedSub.uuid = y.name
                  newCachedSub.subscribers = Double(y.subscribers ?? 0)
                  return newCachedSub
//                }
              }
              return nil
            } ?? []
            
            if let x = c.data {
              return context.performAndWait {
                let newCachedSub = CachedMulti(context: context)
                newCachedSub.over_18 = x.over_18 ?? false
                newCachedSub.display_name = x.display_name
                newCachedSub.icon_url = x.icon_url
                newCachedSub.key_color = x.key_color
                newCachedSub.name = x.name
                newCachedSub.path = x.path
                newCachedSub.uuid = x.id
                subs.forEach { cachedSub in
                  newCachedSub.addToSubreddits(cachedSub)
                }
              }
            }
          }
        
        
        await context.perform(schedule: .enqueued) {
          try? context.save()
        }
        return nil
      case .failure(let error):
        //        print("kmkm")
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct MultiContainerResponse: Codable {
    let kind: String?
    var data: MultiData?
  }
}

