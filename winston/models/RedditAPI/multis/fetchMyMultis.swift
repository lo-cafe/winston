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
  func fetchMyMultis() async -> Bool {
    guard let currentCredentialID = RedditCredentialsManager.shared.selectedCredential?.id else { return false }
    
    let params = FetchMyMultisPayload()
    
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/mine", method: .get, params: params, paramsLocation: .queryString, decodable: [MultiContainerResponse].self) {
    case .success(let data):
      let context = PersistenceController.shared.container.newBackgroundContext()
      
      _ = await context.perform(schedule: .enqueued) {
        let multisFetchRequest = NSFetchRequest<CachedMulti>(entityName: "CachedMulti")
        multisFetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
        
        do {
          let existingMultis = try context.fetch(multisFetchRequest)
          let fetchedMultiIds = Set(data.compactMap { $0.data?.id })
          
          // Update or insert new multis
          for multiDataContainer in data {
            guard let multiData = multiDataContainer.data else { continue }
            
            if let existingMulti = existingMultis.first(where: { $0.uuid == multiData.id }) {
              existingMulti.update(multiData, credentialID: currentCredentialID) // Ensure the update function is implemented to update existing entities
            } else {
              let _ = CachedMulti(data: multiData, context: context, credentialID: currentCredentialID) // Adjust initializer as necessary
            }
          }
          
          // Remove multis not found in fetched data
          existingMultis.forEach { cachedMulti in
            if !fetchedMultiIds.contains(cachedMulti.uuid ?? "") {
              context.delete(cachedMulti)
            }
          }
          
          try withAnimation {
            try context.save()
          }
          return true
        } catch {
          print("Failed to fetch or update multis: \(error)")
          return false
        }
      }
      return true
      
    case .failure(let error):
      print(error)
      return false
    }
  }
  
  //  func fetchMyMultis() async -> Bool? {
  //    guard let currentCredentialID = RedditCredentialsManager.shared.selectedCredential?.id else { return nil }
  //
  //    let params = FetchMyMultisPayload()
  //
  //    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/mine", method: .get, params: params, paramsLocation: .queryString, decodable: [MultiContainerResponse].self) {
  //    case .success(let data):
  //      let context = PersistenceController.shared.container.newBackgroundContext()
  //
  //      let multisFetchRequest = NSFetchRequest<CachedMulti>(entityName: "CachedMulti")
  //      multisFetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
  //      let multisResults = (context.performAndWait { try? context.fetch(multisFetchRequest) }) ?? []
  //
  //      data.forEach { c in
  //        if let data = c.data {
  //          return context.performAndWait {
  //            if let found = multisResults.first(where: { $0.uuid == data.id }) {
  //              found.update(data, credentialID: currentCredentialID)
  //            } else {
  //              _ = CachedMulti(data: data, context: context, credentialID: currentCredentialID)
  //            }
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
  
  struct FetchMyMultisPayload: Codable {
    var expand_srs = true
    var raw_json = 1
  }
  
  struct MultiContainerResponse: Codable {
    let kind: String?
    var data: MultiData?
  }
}

