//
//  readMessage.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func readMessage(_ fullname: String) async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = ReadMessagePayload(id: fullname)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/read_message",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      )
        .serializingString()
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

  struct ReadMessagePayload: Codable {
    var id: String
  }
}
