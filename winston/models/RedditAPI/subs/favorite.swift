//
//  favorite.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func favorite(_ action: Bool, subName: String) async -> Bool {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = FavoritePayload(make_favorite: action, sr_name: subName)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/favorite",
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
  
  struct FavoritePayload: Codable {
    var make_favorite: Bool
    var sr_name: String
  }
}
