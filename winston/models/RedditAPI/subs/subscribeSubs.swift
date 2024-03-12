//
//  subscribeSubs.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func subscribeSubs(action: SubscribeSubAction, subs: [String]) async -> Bool? {
    let params = SubscribeSubPayload(action: action, sr_name: subs.joined(separator: ","))
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/subscribe", method: .post, params: params, paramsLocation: .queryString)  {
    case .success:
      return true
    case .failure:
      //        print(error)
      return nil
    }
  }
  
  struct SubscribeSubPayload: Codable {
    let action: SubscribeSubAction
    var action_source = "o"
    var skip_initial_defaults = true
    let sr_name: String
    var raw_json = 1
    //    let uh: String
  }
  
  enum SubscribeSubAction: String, Codable {
    case sub = "sub"
    case unsub = "unsub"
  }
}
