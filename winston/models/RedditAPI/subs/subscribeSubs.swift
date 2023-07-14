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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = SubscribeSubPayload(action: action, sr_name: subs.joined(separator: ","))
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
        //        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct SubscribeSubPayload: Codable {
    let action: SubscribeSubAction
    var action_source = "o"
    var skip_initial_defaults = true
    let sr_name: String
    //    let uh: String
  }
  
  enum SubscribeSubAction: String, Codable {
    case sub = "sub"
    case unsub = "unsub"
  }
}
