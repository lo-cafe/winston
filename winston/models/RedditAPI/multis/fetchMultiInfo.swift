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
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi\(url)", method: .get, decodable: MultiContainerResponse.self) {
    case .success(let data):
      return data.data
    case .failure:
      //        print(error)
      return nil
    }
  }
}
