//
//  fetchUserOverview.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchUserOverview(_ userName: String, _ after: String? = nil) async -> [Either<PostData, CommentData>]? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      var requestURL = "\(RedditAPI.redditApiURLBase)/user/\(userName)/overview.json"
      if let after = after {
        requestURL += "?after=\(after)"
      }
      
      let response = await AF.request(
        requestURL,
        method: .get,
        headers: headers
      )
      .serializingDecodable(Listing<Either<PostData, CommentData>>.self).response
      
      switch response.result {
      case .success(let data):
        return data.data?.children?.map { $0.data }.compactMap { $0 }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
