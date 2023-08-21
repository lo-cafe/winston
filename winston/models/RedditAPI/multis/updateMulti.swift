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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders(), let myName = me?.data?.name {
      let params = UpdateMultiPayload(
        description_md: description,
        display_name: name,
        key_color: color,
        subreddits: subs.map { MultiSub(name: $0) },
        visibility: visibility
      )
      
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi/user/\(myName)/m/\(name)",
        method: .put,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
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
  
}
