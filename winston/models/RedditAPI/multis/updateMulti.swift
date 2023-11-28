//
//  updateMulti.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  
  struct UpdateMultiPayload: Codable {
    var description_md: String
    let display_name: String
    let key_color: String?
    let subreddits: [MultiSub]
    let visibility: MultiVisibility
  }
  
  func upadteMulti(name: String, displayName: String, subs: [String], description: String = "", color: String? = nil, visibility: MultiVisibility = .pub) async -> Bool? {
    if let myName = me?.data?.name {
      let params = UpdateMultiPayload(
        description_md: description,
        display_name: name,
        key_color: color,
        subreddits: subs.map { MultiSub(name: $0) },
        visibility: visibility
      )
      switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/user/\(myName)/m/\(name)", method: .put, params: params) {
      case .success:
        return true
      case .failure:
        //        print(error)
        return nil
      }
    }
    return nil
  }
  
}
