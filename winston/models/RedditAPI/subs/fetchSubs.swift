//
//  fetchSubs.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire
import Defaults
import SwiftUI
import CoreData

func cleanSubs(_ subs: [ListingChild<SubredditData>]) -> [ListingChild<SubredditData>] {
  return subs.compactMap({ y in
    var x = y
    x.data?.description = ""
    x.data?.description_html = ""
    x.data?.public_description = ""
    x.data?.public_description_html = ""
    x.data?.submit_text_html = ""
    x.data?.submit_text = ""
    return x
  })
}

extension RedditAPI {
  func fetchSubs(after: String? = nil) async -> [ListingChild<SubredditData>]? {
    guard let currentCredentialID = RedditCredentialsManager.shared.selectedCredential?.id else { return [] }

    var params = FetchSubsPayload(limit: 100)
    
    if let after = after {
      params.after = after
    }
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/subreddits/mine/subscriber.json", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<SubredditData>.self)  {
    case .success(let data):
      var finalSubs: [ListingChild<SubredditData>] = []
      if let dataAfter = data.data?.after, !dataAfter.isEmpty, let extraFetchedSubs = await fetchSubs(after: dataAfter) {
        finalSubs += extraFetchedSubs
      }
      if let fetchedSubs = data.data?.children {
        finalSubs += fetchedSubs
      }
      if after != nil {
        return finalSubs
      }
      
      finalSubs = finalSubs.filter { $0.data?.subreddit_type != "user" }
      
      let context = PersistenceController.shared.container.viewContext
      
      let fetchRequest = NSFetchRequest<CachedSub>(entityName: "CachedSub")
      fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
      let results = (context.performAndWait { try? context.fetch(fetchRequest) }) ?? []
      results.forEach { cachedSub in
        context.performAndWait {
          if !finalSubs.contains(where: { listingChild in
            cachedSub.uuid == listingChild.data?.name
          }) {
            context.delete(cachedSub)
          }
        }
      }
      
      await context.perform(schedule: .enqueued) {
        cleanSubs(finalSubs).compactMap { $0.data }.forEach { x in
          if let found = results.first(where: { $0.uuid == x.name }) {
            found.update(data: x, credentialID: currentCredentialID)
          } else {
            _ = CachedSub(data: x, context: context, credentialID: currentCredentialID)
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
  
  struct FetchSubsPayload: Codable {
    var limit: Int
    var after: String?
    //    var show = "all"
    var count = 0
  }
}
