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
    let params = FavoritePayload(make_favorite: action, sr_name: subName)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/favorite", method: .post, params: params, paramsLocation: .queryString)  {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  struct FavoritePayload: Codable {
    var make_favorite: Bool
    var sr_name: String
  }
}
