//
//  deleteComment.swift
//  winston
//
//  Created by Igor Marcossi on 15/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func delete(fullname: String) async -> Bool? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = ["id": fullname]
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/del",
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
}
