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
  
  func fetchAllSubs(after: String? = nil, accumulatedSubs: [ListingChild<SubredditData>]? = nil) async -> [ListingChild<SubredditData>]? {
    // Base case: If 'after' is nil and some subs are already accumulated, simply return them.
    if let after = after, after.isEmpty, let accumulatedSubs = accumulatedSubs {
      return accumulatedSubs
    }
    
    guard let _ = Defaults[.GeneralDefSettings].redditCredentialSelectedID else { return [] }
    
    let params = FetchSubsPayload(limit: 100, after: after)
    
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/subreddits/mine/subscriber.json", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<SubredditData>.self) {
    case .success(let data):
      var newAccumulatedSubs = accumulatedSubs ?? []
      if let fetchedSubs = data.data?.children {
        newAccumulatedSubs += fetchedSubs.filter { $0.data?.subreddit_type != "user" }
      }
      
      if let dataAfter = data.data?.after, !dataAfter.isEmpty {
        // Recursive call with the new 'after' value and the updated accumulated subs.
        return await fetchAllSubs(after: dataAfter, accumulatedSubs: newAccumulatedSubs)
      } else {
        // All subs fetched, return the accumulated result
        return newAccumulatedSubs
      }
    case .failure(let error):
      print(error)
      return accumulatedSubs
    }
  }
  
  func updateSubsInCoreData(with subs: [ListingChild<SubredditData>]) async {
    guard let credentialID = Defaults[.GeneralDefSettings].redditCredentialSelectedID else { return }
    let context = PersistenceController.shared.container.newBackgroundContext()
    
    await context.perform(schedule: .enqueued) {
      let fetchRequest = NSFetchRequest<CachedSub>(entityName: "CachedSub")
      fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", credentialID as CVarArg)
      do {
        let results = try context.fetch(fetchRequest)
        
        // Process the fetched results and update CoreData as needed.
        // Insert or update CachedSub entities with the fetched subs data
        
        for sub in subs.compactMap({ $0.data }) {
          if let existingSub = results.first(where: { $0.uuid == sub.name }) {
            // Update existing CachedSub
            existingSub.update(data: sub, credentialID: credentialID)
          } else {
            // Create new CachedSub
            let newSub = CachedSub(context: context)
            newSub.update(data: sub, credentialID: credentialID)
          }
        }
        
        // Delete CachedSubs not present in the fetched subs
        let currentSubsSet = Set(subs.compactMap { $0.data?.name })
        results.forEach { cachedSub in
          if !currentSubsSet.contains(cachedSub.uuid ?? "") {
            context.delete(cachedSub)
          }
        }
        
        // Save changes
        try withAnimation {
          try context.save()
        }
      } catch {
        print("Failed to fetch or save CachedSubs: \(error)")
      }
    }
  }
  
  func fetchSubsAndSyncCoreData() async {
    if let fetchedSubs = await fetchAllSubs() {
      await updateSubsInCoreData(with: fetchedSubs)
    }
  }
  
  
  //  func fetchSubs(after: String? = nil) async -> [ListingChild<SubredditData>]? {
  //    guard let currentCredentialID = Defaults[.GeneralDefSettings].redditCredentialSelectedID else { return [] }
  //
  //    var params = FetchSubsPayload(limit: 100)
  //
  //    if let after = after {
  //      params.after = after
  //    }
  //    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/subreddits/mine/subscriber.json", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<SubredditData>.self)  {
  //    case .success(let data):
  //      var finalSubs: [ListingChild<SubredditData>] = []
  //      if let dataAfter = data.data?.after, !dataAfter.isEmpty, let extraFetchedSubs = await fetchSubs(after: dataAfter) {
  //        finalSubs += extraFetchedSubs
  //      }
  //      if let fetchedSubs = data.data?.children {
  //        finalSubs += fetchedSubs
  //      }
  //      if after != nil {
  //        return finalSubs
  //      }
  //
  //      finalSubs = finalSubs.filter { $0.data?.subreddit_type != "user" }
  ////      print("aosmao", finalSubs.map { ($0.data?.name, $0.data?.display_name) })
  //      let context = PersistenceController.shared.container.viewContext
  //
  //      let fetchRequest = NSFetchRequest<CachedSub>(entityName: "CachedSub")
  //      fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
  //      let results = (context.performAndWait { try? context.fetch(fetchRequest) }) ?? []
  //      results.forEach { cachedSub in
  //        context.performAndWait {
  //          if !finalSubs.contains(where: { listingChild in
  //            cachedSub.uuid == listingChild.data?.name
  //          }) {
  //            context.delete(cachedSub)
  //          }
  //        }
  //      }
  //
  //      await context.perform(schedule: .enqueued) {
  //        cleanSubs(finalSubs).compactMap { $0.data }.forEach { x in
  //          if let found = results.first(where: { $0.uuid == x.name }) {
  //            found.update(data: x, credentialID: currentCredentialID)
  //          } else {
  //            _ = CachedSub(data: x, context: context, credentialID: currentCredentialID)
  //          }
  //        }
  //      }
  //
  //      await context.perform(schedule: .enqueued) {
  //        try? context.save()
  //      }
  //      return nil
  //    case .failure(let error):
  //      print(error)
  //      return nil
  //    }
  //  }
  
  struct FetchSubsPayload: Codable {
    var limit: Int
    var after: String?
    //    var show = "all"
    var count = 0
    var raw_json = 1
  }
}
