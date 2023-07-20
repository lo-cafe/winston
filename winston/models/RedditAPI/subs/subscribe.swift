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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = SubscribePayload(action: action, sr: subFullname)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/subscribe",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      ).serializingString()
      let result = await dataTask.result
      switch result {
      case .success:
        return true
      case .failure:
        return false
      }
    }
    return false
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
