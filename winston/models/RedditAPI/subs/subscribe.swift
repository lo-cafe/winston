//
//  subscribe.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func subscribe(_ action: SubscribeAction, subFullname: String) async -> Bool {
    let params = SubscribePayload(action: action, sr: subFullname)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/subscribe", method: .post, params: params, paramsLocation: .queryString)  {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  struct SubscribePayload: Codable {
    var action: SubscribeAction
    var action_source = "o"
    var skip_initial_defaults = false
    var sr: String
  }
  
  enum SubscribeAction: String, Codable {
    case sub = "sub"
    case unsub = "unsub"
  }
}
