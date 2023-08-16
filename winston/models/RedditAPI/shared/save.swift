//
//  save.swift
//  winston
//
//  Created by Igor Marcossi on 09/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func save(_ action: Bool, id: String) async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = SavePayload(id: id)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/\(action ? "save" : "unsave")",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      ).serializingString()
      let result = await dataTask.result
      switch result {
      case .success:
        return true
      case .failure:
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct SavePayload: Codable {
    let id: String
  }
}
