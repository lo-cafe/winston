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
    let params = ["expand_srs":true]
    
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/mine", method: .get, params: params, paramsLocation: .queryString, decodable: [MultiContainerResponse].self) {
    case .success(let data):
      let context = PersistenceController.shared.container.newBackgroundContext()
      
      let multisFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedMulti")
      let multisResults = (context.performAndWait { try? context.fetch(multisFetchRequest) as? [CachedMulti] }) ?? []
      
      data.forEach { c in
        if let data = c.data {
          return context.performAndWait {
            if let found = multisResults.first(where: { $0.uuid == data.id }) {
              found.update(data)
            } else {
              _ = CachedMulti(data: data, context: context)
            }
          }
        }
      }
      
      await context.perform(schedule: .enqueued) {
        try? context.save()
      }
      return nil
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  struct MultiContainerResponse: Codable {
    let kind: String?
    var data: MultiData?
  }
}

