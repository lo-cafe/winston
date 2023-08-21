//
//  fetchMultiInfo.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMultiInfo(_ url: String) async -> MultiData? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi\(url)",
        method: .get,
        headers: headers
      ).serializingDecodable(MultiContainerResponse.self).response
      switch response.result {
      case .success(let data):
        return data.data
      case .failure:
        //        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
